import Foundation

public struct Constants {
    public struct Container {
        public static let SignedContainerFolder = "SignedContainers"
        public static let DefaultName = "newFile"
        public static let ContainerExtensions = [
            Extension.Asice,
            Extension.Sce,
            Extension.Adoc,
            Extension.Bdoc,
            Extension.Ddoc,
            Extension.Edoc,
            Extension.Asics,
            Extension.Scs
        ]
    }

    public struct MimeType {
        public static let Asice = "application/vnd.etsi.asic-e+zip" // Also .bdoc, .edoc, .sce
        public static let Asics = "application/vnd.etsi.asic-s+zip" // Also .scs
        public static let Ddoc = "application/x-ddoc"
        public static let Bdoc = "application/vnd.bdoc-1.0"
        public static let Adoc = "application/vnd.lt.archyvai.adoc-2008"
        public static let SignatureContainers = [Asice, Asics, Ddoc, Bdoc, Adoc]

        public static let Pdf = "application/pdf"

        public static let Container = "application/octet-stream"
        public static let Default = "text/plain"
    }

    public struct Extension {
        public static let Pdf = "pdf"
        public static let Default = "asice"
        public static let Asice = "asice"
        public static let Asics = "asics"
        public static let Ddoc = "ddoc"
        public static let Sce = "sce"
        public static let Adoc = "adoc"
        public static let Bdoc = "bdoc"
        public static let Edoc = "edoc"
        public static let Scs = "scs"
    }

    public struct Identifier {
        public static let Group = "group.ee.ria.digidoc.ios"
        public static let GroupDownload = "group.ee.ria.digidoc.ios.download"
    }

    public struct Folder {
        public static let Temp = "tempfiles"
        public static let Shared = "shareddownloads"
    }
}
