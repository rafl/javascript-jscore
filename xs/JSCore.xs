#include "perl_jscore.h"

MODULE = JavaScript::JSCore	PACKAGE = JavaScript::JSCore

BOOT:
	PERL_JSCORE_CALL_BOOT (boot_JavaScript__JSCore__Context);
	PERL_JSCORE_CALL_BOOT (boot_JavaScript__JSCore__Context__Global);
	PERL_JSCORE_CALL_BOOT (boot_JavaScript__JSCore__Value);
	PERL_JSCORE_CALL_BOOT (boot_JavaScript__JSCore__Class);
	PERL_JSCORE_CALL_BOOT (boot_JavaScript__JSCore__Object);
	PERL_JSCORE_CALL_BOOT (boot_JavaScript__JSCore__Object__Temp);
