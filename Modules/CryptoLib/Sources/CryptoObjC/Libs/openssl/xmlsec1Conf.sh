#
# Configuration file for using the XML library in GNOME applications
#
prefix="/Library/libdigidocpp.iphoneos"
exec_prefix="${prefix}"
libdir="${exec_prefix}/lib"
includedir="${prefix}/include"

XMLSEC_LIBDIR="${exec_prefix}/lib"
XMLSEC_INCLUDEDIR=" -D__XMLSEC_FUNCTION__=__func__ -DXMLSEC_NO_XSLT=1 -DXMLSEC_NO_FTP=1 -DXMLSEC_NO_HTTP=1 -DXMLSEC_NO_MD5=1 -DXMLSEC_NO_RIPEMD160=1 -DXMLSEC_NO_GOST=1 -DXMLSEC_NO_GOST2012=1 -DXMLSEC_NO_CRYPTO_DYNAMIC_LOADING=1 -I${prefix}/include/xmlsec1      -I/Library/libdigidocpp.iphoneos/include -DXMLSEC_CRYPTO_OPENSSL=1"
XMLSEC_LIBS="-L${exec_prefix}/lib -lxmlsec1-openssl -lxmlsec1   -lxml2   -L/Library/libdigidocpp.iphoneos/lib -lcrypto "
MODULE_VERSION="xmlsec-1.3.7-openssl"

