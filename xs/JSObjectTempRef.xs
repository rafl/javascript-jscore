#include "perl_jscore.h"

MODULE = JavaScript::JSCore::Object::Temp	PACKAGE = JavaScript::JSCore::Object::Temp

void
DESTROY (obj)
		SV *obj
	CODE:
		PERL_UNUSED_VAR (obj);

BOOT:
	perl_jscore_prepend_isa ("JavaScript::JSCore::Object::Temp", "JavaScript::JSCore::Object");
