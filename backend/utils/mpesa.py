"""
M-Pesa Daraja API integration (STK Push).

Designed as plug-and-play:
  - When MPESA_CONSUMER_KEY and MPESA_CONSUMER_SECRET are empty (default),
    mock_* functions simulate the flow.
  - When credentials are filled in .env, real_* functions take over.

To switch to live: fill MPESA_CONSUMER_KEY, MPESA_CONSUMER_SECRET,
MPESA_PASSKEY in .env and set MPESA_ENV=production.
"""
import json
import os
import requests
from datetime import datetime
from base64 import b64encode


def get_config():
    return {
        "consumer_key": os.environ.get("MPESA_CONSUMER_KEY", ""),
        "consumer_secret": os.environ.get("MPESA_CONSUMER_SECRET", ""),
        "passkey": os.environ.get("MPESA_PASSKEY", ""),
        "shortcode": os.environ.get("MPESA_SHORTCODE", "174379"),
        "env": os.environ.get("MPESA_ENV", "sandbox"),
    }


def _get_auth_token(cfg) -> str:
    """Get OAuth token from Safaricom."""
    if not cfg["consumer_key"]:
        return "mock_token"
    auth_url = (
        "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        if cfg["env"] == "sandbox"
        else "https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    )
    resp = requests.get(
        auth_url,
        auth=(cfg["consumer_key"], cfg["consumer_secret"]),
        timeout=10,
    )
    return resp.json().get("access_token", "")


def _generate_password(cfg, timestamp: str) -> str:
    """Generate STK push password."""
    data = cfg["shortcode"] + cfg["passkey"] + timestamp
    return b64encode(data.encode()).decode()


def initiate_stk_push(phone: str, amount: int, account_ref: str) -> dict:
    """Initiate M-Pesa STK Push. Returns mock response if keys not configured."""
    cfg = get_config()
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")

    if not cfg["consumer_key"] or not cfg["consumer_secret"]:
        return {
            "success": True,
            "mock": True,
            "message": "M-Pesa is in mock mode. Set MPESA_CONSUMER_KEY in .env for real payments.",
            "CheckoutRequestID": "mock_" + timestamp,
            "amount": amount,
            "phone": phone,
            "account_ref": account_ref,
        }

    token = _get_auth_token(cfg)
    password = _generate_password(cfg, timestamp)

    api_url = (
        "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
        if cfg["env"] == "sandbox"
        else "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    )

    payload = {
        "BusinessShortCode": cfg["shortcode"],
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phone,
        "PartyB": cfg["shortcode"],
        "PhoneNumber": phone,
        "CallBackURL": "",  # Set via ngrok or deployed URL
        "AccountReference": account_ref[:12],
        "TransactionDesc": f"RentalHub {account_ref}",
    }

    resp = requests.post(
        api_url,
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
        timeout=15,
    )
    return resp.json()
