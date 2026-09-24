// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit

extension Container {
    public var digiDocConf: Factory<DigiDocConfProtocol> {
        self { DigiDocConf() }
    }

    public var signedContainer: Factory<SignedContainerProtocol> {
        self {
            SignedContainer(
                container: self.containerWrapper(),
                fileManager: self.fileManager(),
                containerUtil: self.containerUtil()
            )
        }
    }

    public var containerWrapper: Factory<ContainerWrapperProtocol> {
        self { ContainerWrapper(fileManager: self.fileManager()) }
    }
}
