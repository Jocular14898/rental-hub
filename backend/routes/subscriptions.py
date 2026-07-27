from datetime import datetime, timezone, timedelta
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Subscription, SUBSCRIPTION_PRICES
from utils.mpesa import initiate_stk_push

bp = Blueprint("subscriptions", __name__, url_prefix="/api/subscriptions")


@bp.route("/plans", methods=["GET"])
def list_plans():
    return jsonify(SUBSCRIPTION_PRICES)


@bp.route("/initiate", methods=["POST"])
@jwt_required()
def initiate():
    user = User.query.get(get_jwt_identity())
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}
    plan_type = data.get("plan_type", user.user_type)
    if plan_type not in SUBSCRIPTION_PRICES:
        return jsonify({"error": "Invalid plan type"}), 400

    amount = SUBSCRIPTION_PRICES[plan_type]
    phone = data.get("phone", user.phone)

    # Initiate M-Pesa STK Push
    result = initiate_stk_push(
        phone=phone,
        amount=amount,
        account_ref=f"{user.id[:8]}_{plan_type}",
    )

    # Create subscription record (pending)
    sub = Subscription(
        user_id=user.id,
        plan_type=plan_type,
        status="pending",
        amount=amount,
    )
    db.session.add(sub)
    db.session.commit()

    return jsonify({
        "subscription": sub.to_dict(),
        "mpesa": result,
    }), 201


@bp.route("/callback", methods=["POST"])
def mpesa_callback():
    """M-Pesa API callback endpoint.
    
    Configure this URL (via ngrok or deployed domain) in your
    Safaricom Daraja API callback settings.
    """
    data = request.get_json() or {}
    # Extract transaction details from Safaricom callback
    # Structure: { "Body": { "stkCallback": { ... } } }
    body = data.get("Body", {})
    callback = body.get("stkCallback", {})
    result_code = callback.get("ResultCode", 1)
    checkout_id = callback.get("CheckoutRequestID", "")

    if result_code == 0:
        # Payment successful — activate subscription
        metadata = callback.get("CallbackMetadata", {}).get("Item", [])
        txn_id = ""
        for item in metadata:
            if item.get("Name") == "MpesaReceiptNumber":
                txn_id = item.get("Value", "")

        sub = Subscription.query.filter_by(
            mpesa_transaction_id=checkout_id
        ).first()
        if not sub:
            # Find by account reference
            account_ref = checkout_id  # simplified
            sub = Subscription.query.filter(
                Subscription.status == "pending"
            ).order_by(Subscription.created_at.desc()).first()

        if sub:
            sub.status = "active"
            sub.mpesa_transaction_id = txn_id or checkout_id
            sub.start_date = datetime.now(timezone.utc)
            sub.end_date = sub.start_date + timedelta(days=30)
            db.session.commit()

    return jsonify({"ResultCode": 0, "ResultDesc": "Success"})


@bp.route("/status", methods=["GET"])
@jwt_required()
def status():
    user_id = get_jwt_identity()
    subs = Subscription.query.filter_by(user_id=user_id).order_by(
        Subscription.created_at.desc()
    ).all()
    return jsonify({
        "active": any(s.is_active() for s in subs),
        "subscriptions": [s.to_dict() for s in subs],
    })
