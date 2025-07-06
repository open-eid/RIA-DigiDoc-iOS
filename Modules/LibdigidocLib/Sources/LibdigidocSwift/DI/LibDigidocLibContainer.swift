import FactoryKit

extension Container {
    public var digiDocConf: Factory<DigiDocConfProtocol> {
        self { DigiDocConf() }
    }

    public var signedContainer: Factory<SignedContainerProtocol> {
        self {
            SignedContainer(
                fileManager: self.fileManager(),
                containerUtil: self.containerUtil()
            )
        }
    }

    public var containerWrapper: Factory<ContainerWrapperProtocol> {
        self { ContainerWrapper() }
    }
}
