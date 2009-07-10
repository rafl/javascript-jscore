#include "perl_jscore.h"

MODULE = JavaScript::JSCore::Value	PACKAGE = JavaScript::JSCore::Value

JSType
get_type (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueGetType (ctx, value);
	OUTPUT:
		RETVAL

bool
is_undefined (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsUndefined (ctx, value);
	OUTPUT:
		RETVAL

bool
is_null (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsNull (ctx, value);
	OUTPUT:
		RETVAL

bool
is_boolean (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsBoolean (ctx, value);
	OUTPUT:
		RETVAL

bool
is_number (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsNumber (ctx, value);
	OUTPUT:
		RETVAL

bool
is_string (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsString (ctx, value);
	OUTPUT:
		RETVAL

bool
is_object (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsObject (ctx, value);
	OUTPUT:
		RETVAL

bool
is_object_of_class (value, class, ctx=NULL)
		JSValueRef value
		JSClassRef class
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsObjectOfClass (ctx, value, class);
	OUTPUT:
		RETVAL

bool
is_equal (a, b, ctx=NULL)
		JSValueRef a
		JSValueRef b
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsEqual (ctx, a, b, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL

bool
is_strict_equal (a, b, ctx=NULL)
		JSValueRef a
		JSValueRef b
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsStrictEqual (ctx, a, b);
	OUTPUT:
		RETVAL

bool
is_instance_of_constructor (value, constructor, ctx=NULL)
		JSValueRef value
		JSObjectRef constructor
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueIsInstanceOfConstructor (ctx, value, constructor, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL

bool
to_boolean (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueToBoolean (ctx, value);
	OUTPUT:
		RETVAL

double
to_number (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueToNumber (ctx, value, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL

JSStringRef
to_string (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueToStringCopy (ctx, value, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		JSStringRelease (RETVAL);

JSObjectRef
to_object (value, ctx=NULL)
		JSValueRef value
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSValueToObject (ctx, value, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL

void
DESTROY (value)
		SV *value
	CODE:
		warn ("destroy value");
		SvREFCNT_dec (SvRV (PERL_JSCORE_VALUE_GET_CTX (value)));
