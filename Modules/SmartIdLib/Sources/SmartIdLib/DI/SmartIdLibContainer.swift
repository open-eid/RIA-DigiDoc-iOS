// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FactoryKit

extension Container {
    var sessionProvider: Factory<SessionProviderProtocol> {
        self { SessionProvider() }
    }

    var responseHandler: Factory<ResponseHandlerProtocol> {
        self { ResponseHandler() }
    }

    var requestPerfomer: Factory<RequestPerfomerProtocol> {
        self {
            RequestPerformer(
                sessionProvider: self.sessionProvider(),
                responseHandler: self.responseHandler()
            )
        }
    }

    public var smartIdSignService: Factory<SmartIdSignServiceProtocol> {
        self {
            SmartIdSignService(
                requestPerfomer: self.requestPerfomer()
            )
        }
    }
}
