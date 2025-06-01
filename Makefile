-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployTicketMaster.s.sol:DeployTicketMaster --rpc-url $(SEPOLIA_RPC_ULR) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv