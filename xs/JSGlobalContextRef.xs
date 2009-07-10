#include "perl_jscore.h"

MODULE = JavaScript::JSCore::Context::Global	PACKAGE = JavaScript::JSCore::Context::Global

JSGlobalContextRef
create (klass, global_object_class=NULL)
		JSClassRef global_object_class
	CODE:
		RETVAL = JSGlobalContextCreate (global_object_class);
		warn ("new ctx 0x%x", (unsigned int)RETVAL);
	OUTPUT:
		RETVAL

void
DESTROY (ctx)
		JSGlobalContextRef ctx
	CODE:
		JSGlobalContextRelease (ctx);

BOOT:
	perl_jscore_prepend_isa ("JavaScript::JSCore::Context::Global", "JavaScript::JSCore::Context");
