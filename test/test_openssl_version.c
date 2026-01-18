#include <stdio.h>
#include <openssl/crypto.h>
#include <openssl/opensslv.h>

int main() {
    printf("=== OpenSSL Version Info Test ===\n\n");

    printf("OpenSSL_version(OPENSSL_VERSION): '%s'\n", OpenSSL_version(OPENSSL_VERSION));
    printf("OpenSSL_version(OPENSSL_CFLAGS): '%s'\n", OpenSSL_version(OPENSSL_CFLAGS));
    printf("OpenSSL_version(OPENSSL_BUILT_ON): '%s'\n", OpenSSL_version(OPENSSL_BUILT_ON));
    printf("OpenSSL_version(OPENSSL_PLATFORM): '%s'\n", OpenSSL_version(OPENSSL_PLATFORM));
    printf("OpenSSL_version(OPENSSL_DIR): '%s'\n", OpenSSL_version(OPENSSL_DIR));
    printf("OpenSSL_version(OPENSSL_ENGINES_DIR): '%s'\n", OpenSSL_version(OPENSSL_ENGINES_DIR));
    printf("OpenSSL_version(OPENSSL_MODULES_DIR): '%s'\n", OpenSSL_version(OPENSSL_MODULES_DIR));

    printf("\n=== OPENSSL_info() Test ===\n\n");

    const char* info;
    info = OPENSSL_info(OPENSSL_INFO_CONFIG_DIR);
    printf("OPENSSL_info(CONFIG_DIR): '%s'\n", info ? info : "(null)");

    info = OPENSSL_info(OPENSSL_INFO_ENGINES_DIR);
    printf("OPENSSL_info(ENGINES_DIR): '%s'\n", info ? info : "(null)");

    info = OPENSSL_info(OPENSSL_INFO_MODULES_DIR);
    printf("OPENSSL_info(MODULES_DIR): '%s'\n", info ? info : "(null)");

    printf("\n=== Expected: All values should be empty or null ===\n");

    return 0;
}
