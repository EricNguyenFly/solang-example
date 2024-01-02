import "../libraries/spl_token.sol";
import "../libraries/mpl_metadata.sol";
import "solana";

@program_id("9Egc382nPtM559Zq4ucp3FSH1nhiPRqdpr5Zodnnsoko")
contract airdrop {
    address public owner;
    uint128 public startTime;
    uint128 public endTime;
    uint64 public amountClaim;
    uint64 public totalClaimed;

    mapping(address => bool) whitelists;

    @payer(payer)
    constructor(uint128 start_time, uint128 end_time, uint64 amount_claim, address initial_authority) {
        startTime = start_time;
        endTime = end_time;
        amountClaim = amount_claim;
        owner = initial_authority;
    }

    @signer(owner)
    function deposit(uint64 _amount) external {
        require(tx.accounts.owner.is_signer, "Caller is not an owner");
        require(_amount > 0, "Invalid amount");
        SplToken.transfer(
            tx.accounts.owner.key, address(this), tx.accounts.owner.key, _amount
        );
    }

    function withdraw() external {
        require(endTime >= block.timestamp, "Drop is not end");
        uint64 amount = SplToken.get_balance(address(this));
        SplToken.transfer(
            address(this), owner, address(this), amount
        );
    }

    @account(account)
    function claim() external {
        require(isWhitelist(tx.accounts.account.key), "User is not white list");
        SplToken.transfer(
            address(this), tx.accounts.account.key, address(this), amountClaim
        );
    }

    @signer(owner)
    function addWhiteLists(address[] addrs) external {
        require(tx.accounts.owner.is_signer, "Caller is not an owner");
        require(addrs.length > 0, "Invalid length");
        for (uint128 i = 0; i < addrs.length; i++) {
            require(addrs[i] != address(0), "Invalid address");
            whitelists[addrs[i]] = true;
        }
    }

    @signer(owner)
    function addWhiteList(address addr) external {
        require(tx.accounts.owner.is_signer, "Caller is not an owner");
        require(addr != address(0), "Invalid address");
        whitelists[addr] = true;
    }

    function isWhitelist(address addr) public view returns (bool) {
        return whitelists[addr];
    }

    @signer(owner)
    function removeWhiteList(address addr) external {
        require(tx.accounts.owner.is_signer, "Caller is not an owner");
        delete whitelists[addr];
    }
}
