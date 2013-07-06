local privateKey = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK6LTQ2HGVP6KOKjwkWpYZWNv+Z2t5H4Z5D4v9msQqP1Sg4x00cZo3DsN2eIUTV6F3D1aBCvjlzAfxURSh+sMkJsq7OrE3kj+UC2siYhA1BSJVhKjBVy+Dd+d2Cc54WlrnWX4N75kXf6sO0+0WI3XkBSfEV2cCunKu/aOefOna5nAgMBAAECgYAzO9Z5Qw+vM73ukM0Er6xiPsJ2fqBxq22TA0ElPsgs4mJDemKe+yqbierVbBESVm0tDgvm4fEyzpo+791HIL97fZ1od4j0p9w3hrBDOrZlR470wpU+T3BsmS67n/isc1cOFwf1TP/q/VxwaP9JS2ll6YfsnUUOtp/ENXF6iOvsgQJBAOENLd56kD0aHZHwy2SKaI1Y8RBlEoOVo6+tk9BsHH9l+Tmk2on7NlmskJcmA/TNxm+eMXzqYbyBuFC8q8nnAicCQQDGjAmE+6Z46XISnqYqHovXAA83W5QIddVGBVCFrmMKh6bU8DnCpo70y+nsbyx0D0tIm2DB6gXAk2GZkazjjtnBAkEAinXyT5v2nDEyGjUc3gmt07Dx95VHs79gCtjvRV8OlW8my8laT2RIhxl9iBDyhC4KNWgNqH4HjdP9k2bRBpJjJwJAB8YX4VMRE47gXoZDr0Z+5y4jamF1jFdAwHsYygMn8ZOaHqBBQrPOyRrqz80SioDGy9L5mN4W15FtstuXT1magQJAB9zCQQPKeWfg6RkS96evowtlfaruYXcu3Plrd1fF2Au1GdDXGe7G8n7rQpo6oOjEDxn2FG3xiTUwLd4FhfBNeA=="
local publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCui00NhxlT+ijio8JFqWGVjb/mdreR+GeQ+L/ZrEKj9UoOMdNHGaNw7DdniFE1ehdw9WgQr45cwH8VEUofrDJCbKuzqxN5I/lAtrImIQNQUiVYSowVcvg3fndgnOeFpa51l+De+ZF3+rDtPtFiN15AUnxFdnArpyrv2jnnzp2uZwIDAQAB"
local partner = "2088602076893360"
local seller = "2088602076893360"
local notify_url = "http://uhz000738.chinaw3.com/test"
Alipay = {}

function Alipay.getOutTradeNo(uid)
    local t = os.time()
    return t .. "" .. uid
end

function Alipay.makeRequestInfo(uid, subName, subInfo, cost)
    local str = "partner=\"" .. partner .. "\"&seller=\"" .. seller .. "\"&out_trade_no=\"" .. Alipay.getOutTradeNo(uid)
        .. "\"&subject=\"" .. subName .. "\"&body=\"" .. subInfo .. "\"&total_fee=\"" .. cost .. "\"&notify_url=\"" .. notify_url .. "\"";
        
    local signStr = CCCrypto:rsaSign(str, privateKey)
    --local encodeSign = urlEncode(signStr)
    return str .. "&sign=\"" .. signStr .. "\"&sign_type=\"RSA\""
end