import Foundation

public struct Constants {
    public struct Container {
        public static let SignedContainerFolder = "SignedContainers"
    }

    public struct MimeType {
        public static let Asice = "application/vnd.etsi.asic-e+zip" // Also .bdoc, .edoc, .sce
        public static let Asics = "application/vnd.etsi.asic-s+zip" // Also .scs
        public static let Ddoc = "application/x-ddoc"
        public static let Adoc = "application/vnd.lt.archyvai.adoc-2008"
        public static let SignatureContainers = [Asice, Asics, Ddoc, Adoc]

        public static let Pdf = "application/pdf"

        public static let Container = "application/octet-stream"
        public static let Default = "text/plain"
    }

    public struct Extension {
        public static let Pdf = "pdf"
        public static let Default = "asice"
    }
}
