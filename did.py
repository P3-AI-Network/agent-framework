from eth_account import Account
from eth_account.messages import encode_defunct
from web3 import Web3
import didkit
import json

def create_ethereum_did():

    acct = Account.create()
    private_key = acct.key.hex()
    address = acct.address
    
    w3 = Web3(Web3.HTTPProvider('https://mainnet.optimism.io')
    
    did = f"did:ethr:optimism:{address}"
    
    verification_method = {
        "id": f"{did}#controller",
        "type": "EcdsaSecp256k1RecoveryMethod2020",
        "controller": did,
        "blockchainAccountId": f"eip155:10:{address}"
    }
    
    # Create DID Document
    did_document = {
        "@context": [
            "https://www.w3.org/ns/did/v1",
            "https://w3id.org/security/suites/secp256k1recovery-2020/v2"
        ],
        "id": did,
        "verificationMethod": [verification_method],
        "authentication": [verification_method["id"]],
        "assertionMethod": [verification_method["id"]]
    }
    
    # Sign the DID document
    message = json.dumps(did_document)
    message_hash = encode_defunct(text=message)
    signed = w3.eth.account.sign_message(message_hash, private_key=private_key)
    
    return {
        "did": did,
        "did_document": did_document,
        "private_key": private_key,
        "address": address,
        "signature": signed.signature.hex()
    }

def verify_did(did_info):
    """Verify the DID document signature"""
    message = json.dumps(did_info["did_document"])
    message_hash = encode_defunct(text=message)
    
    recovered_address = Account.recover_message(
        message_hash,
        signature=did_info["signature"]
    )
    
    return recovered_address.lower() == did_info["address"].lower()

# Usage example
def main():
    try:
        # Create DID
        did_info = create_ethereum_did()
        
        print(f"Created DID: {did_info['did']}")
        print(f"Ethereum Address: {did_info['address']}")
        print("\nDID Document:")
        print(json.dumps(did_info['did_document'], indent=2))
        
        # Verify DID
        is_valid = verify_did(did_info)
        print(f"\nDID Verification: {'Success' if is_valid else 'Failed'}")
        
        return did_info
        
    except Exception as e:
        print(f"Error creating DID: {str(e)}")
        return None

if __name__ == "__main__":
    main()