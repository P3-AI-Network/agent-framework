// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDRegistry {
    // Struct to store DID information
    struct DIDDocument {
        string document;        // The DID document stored as a JSON string
        address controller;     // The address that controls this DID
        uint256 timestamp;     // Last update timestamp
        bool active;           // Whether the DID is active
    }
    
    // Mapping from DID string to DID Document
    mapping(string => DIDDocument) private didDocuments;
    
    // Mapping to track delegated controllers for DIDs
    mapping(string => mapping(address => bool)) private delegates;
    
    // Events
    event DIDRegistered(string indexed did, address controller);
    event DIDUpdated(string indexed did, address updater);
    event DIDDeactivated(string indexed did);
    event DelegateAdded(string indexed did, address delegate);
    event DelegateRemoved(string indexed did, address delegate);
    
    // Modifiers
    modifier onlyController(string memory did) {
        require(
            didDocuments[did].controller == msg.sender || delegates[did][msg.sender],
            "Not authorized to modify this DID"
        );
        _;
    }
    
    modifier didExists(string memory did) {
        require(didDocuments[did].controller != address(0), "DID does not exist");
        _;
    }
    
    modifier didActive(string memory did) {
        require(didDocuments[did].active, "DID is not active");
        _;
    }
    
    /**
     * @dev Register a new DID with its document
     * @param did The DID string (e.g., "did:ethr:0x123...")
     * @param document The DID document as a JSON string
     */
    function registerDID(string memory did, string memory document) public {
        require(didDocuments[did].controller == address(0), "DID already registered");
        
        didDocuments[did] = DIDDocument({
            document: document,
            controller: msg.sender,
            timestamp: block.timestamp,
            active: true
        });
        
        emit DIDRegistered(did, msg.sender);
    }
    
    /**
     * @dev Update an existing DID document
     * @param did The DID to update
     * @param newDocument The new DID document
     */
    function updateDID(string memory did, string memory newDocument) 
        public 
        didExists(did) 
        didActive(did) 
        onlyController(did) 
    {
        didDocuments[did].document = newDocument;
        didDocuments[did].timestamp = block.timestamp;
        
        emit DIDUpdated(did, msg.sender);
    }
    
    /**
     * @dev Add a delegate for a DID
     * @param did The DID to add a delegate for
     * @param delegate The address to add as a delegate
     */
    function addDelegate(string memory did, address delegate) 
        public 
        didExists(did) 
        didActive(did) 
        onlyController(did) 
    {
        require(delegate != address(0), "Invalid delegate address");
        require(!delegates[did][delegate], "Already a delegate");
        
        delegates[did][delegate] = true;
        
        emit DelegateAdded(did, delegate);
    }
    
    /**
     * @dev Remove a delegate for a DID
     * @param did The DID to remove a delegate from
     * @param delegate The address to remove as a delegate
     */
    function removeDelegate(string memory did, address delegate) 
        public 
        didExists(did) 
        didActive(did) 
        onlyController(did) 
    {
        require(delegates[did][delegate], "Not a delegate");
        
        delegates[did][delegate] = false;
        
        emit DelegateRemoved(did, delegate);
    }
    
    /**
     * @dev Deactivate a DID
     * @param did The DID to deactivate
     */
    function deactivateDID(string memory did) 
        public 
        didExists(did) 
        didActive(did) 
        onlyController(did) 
    {
        didDocuments[did].active = false;
        
        emit DIDDeactivated(did);
    }
    
    /**
     * @dev Resolve a DID to get its document
     * @param did The DID to resolve
     * @return document The DID document
     * @return controller The controller address
     * @return timestamp Last update timestamp
     * @return active Whether the DID is active
     */
    function resolveDID(string memory did) 
        public 
        view 
        returns (
            string memory document,
            address controller,
            uint256 timestamp,
            bool active
        ) 
    {
        DIDDocument memory didDoc = didDocuments[did];
        require(didDoc.controller != address(0), "DID does not exist");
        
        return (
            didDoc.document,
            didDoc.controller,
            didDoc.timestamp,
            didDoc.active
        );
    }
    
    /**
     * @dev Check if an address is a delegate for a DID
     * @param did The DID to check
     * @param delegate The address to check
     * @return bool True if the address is a delegate
     */
    function isDelegate(string memory did, address delegate) 
        public 
        view 
        returns (bool) 
    {
        return delegates[did][delegate];
    }
    
    /**
     * @dev Check if a DID exists
     * @param did The DID to check
     * @return bool True if the DID exists
     */
    function didExistsfunc(string memory did) 
        public 
        view 
        didExists(did) 
        returns (bool) 
    {
        return didDocuments[did].controller != address(0);
    }
}