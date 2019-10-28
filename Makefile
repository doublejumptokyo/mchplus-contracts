OPENZEPPELIN_VERSION=2.3.0

exec: contracts/lib/github.com/OpenZeppelin/openzeppelin-contracts-$(OPENZEPPELIN_VERSION)


contracts/lib/github.com/OpenZeppelin/openzeppelin-contracts-$(OPENZEPPELIN_VERSION):
	mkdir -p contracts/lib/github.com/OpenZeppelin/
	curl https://codeload.github.com/OpenZeppelin/openzeppelin-contracts/tar.gz/v$(OPENZEPPELIN_VERSION) | tar zx -C  contracts/lib/github.com/OpenZeppelin/
