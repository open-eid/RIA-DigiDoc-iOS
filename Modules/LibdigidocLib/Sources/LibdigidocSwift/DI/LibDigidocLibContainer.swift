import FactoryKit

extension Container {
    public var digiDocConf: Factory<DigiDocConfProtocol> {
        self { DigiDocConf() }
    }

    public var signedContainer: Factory<SignedContainerProtocol> {
        self { SignedContainer() }
    }

    public var containerWrapper: Factory<ContainerWrapperProtocol> {
        self { ContainerWrapper() }
    }
}
