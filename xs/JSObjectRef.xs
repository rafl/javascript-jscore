#include "perl_jscore.h"

MODULE = JavaScript::JSCore::Object	PACKAGE = JavaScript::JSCore::Object

JSValueRef
get_prototype (object, ctx=NULL)
		JSObjectRef object
		SV *ctx;
	PREINIT:
		JSContextRef cctx;
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CTX (ST (0));
		}

		cctx = SvJSContextRef (ctx);
	CODE:
		RETVAL = JSObjectGetPrototype (cctx, object);
	OUTPUT:
		RETVAL
	CLEANUP:
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx);

void
set_prototype (object, value, ctx=NULL)
		JSObjectRef object
		JSValueRef value
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		JSObjectSetPrototype (ctx, object, value);

bool
has_property (object, property_name, ctx=NULL)
		JSObjectRef object
		JSStringRef property_name
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSObjectHasProperty (ctx, object, property_name);
	OUTPUT:
		RETVAL

JSValueRef
get_property (object, property_name, ctx=NULL)
		JSObjectRef object
		JSStringRef property_name
		SV *ctx
	PREINIT:
		JSContextRef cctx;
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CTX (ST (0));
		}

		cctx = SvJSContextRef (ctx);
	CODE:
		RETVAL = JSObjectGetProperty (cctx, object, property_name, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx);

void
set_property (object, property_name, value, ...)
		JSObjectRef object
		JSStringRef property_name
		JSValueRef value
	PREINIT:
		JSPropertyAttributes attributes = kJSPropertyAttributeNone;
		JSContextRef ctx;
		JSValueRef exception = NULL; /* TODO */
	INIT:
		switch (items) {
			case 5:
				ctx = SvJSContextRef (ST (4));
			case 4:
				attributes = SvPropertyAttributes (ST (3));
			case 3:
				break;
		}

		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		JSObjectSetProperty (ctx, object, property_name, value, attributes, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}

bool
delete_property (object, property_name, ctx=NULL)
		JSObjectRef object
		JSStringRef property_name
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx= PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSObjectDeleteProperty (ctx, object, property_name, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL

JSValueRef
get_property_at_index (object, property_index, ctx=NULL)
		JSObjectRef object
		unsigned property_index
		SV *ctx
	PREINIT:
		JSContextRef cctx;
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CTX (ST (0));
		}

		cctx = SvJSContextRef (ctx);
	CODE:
		RETVAL = JSObjectGetPropertyAtIndex (cctx, object, property_index, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx);

void
set_property_at_index (object, property_index, value, ctx=NULL)
		JSObjectRef object
		unsigned property_index
		JSValueRef value
		JSContextRef ctx
	PREINIT:
		JSValueRef exception = NULL; /* TODO */
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		JSObjectSetPropertyAtIndex (ctx, object, property_index, value, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}

bool
is_function (object, ctx=NULL)
		JSObjectRef object
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSObjectIsFunction (ctx, object);
	OUTPUT:
		RETVAL

JSValueRef
call_as_function (object, ...)
		JSObjectRef object
	PREINIT:
		SV *ctx, *tmp;
		JSContextRef cctx;
		JSObjectRef this_object = NULL;
		size_t argument_count = 0;
		JSValueRef *arguments = NULL;
		JSValueRef exception = NULL;
		SV **he;
		int i, n_items;
	INIT:
		n_items = items;
		tmp = ST (items - 1);
		if (tmp && SvOK (tmp) && SvROK (tmp) && (SvTYPE (SvRV (tmp)) == SVt_PVHV)) {
			n_items--;

			he = hv_fetch ((HV *)SvRV (tmp), "ctx", sizeof ("ctx"), 0);
			if (he && *he) {
				ctx = *he;
			}
			else {
				ctx = PERL_JSCORE_VALUE_GET_CTX (ST (0));
			}

			cctx = SvJSContextRef (ctx);

			he = hv_fetch ((HV *)SvRV (tmp), "this", sizeof ("this"), 0);
			if (he && *he) {
				this_object = SvJSObjectRef (*he);
			}
		}

		arguments = (JSValueRef*)malloc (sizeof (JSValueRef) * n_items - 1);
		argument_count = n_items - 1;

		for (i = 1; i < n_items; i++) {
			arguments[i - 1] = SvJSValueRef (ST (i));
		}
	CODE:
		RETVAL = JSObjectCallAsFunction (cctx, object, this_object, argument_count, arguments, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		free (arguments);
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx);

bool
is_constructor (object, ctx=NULL)
		JSObjectRef object
		JSContextRef ctx
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		RETVAL = JSObjectIsConstructor (ctx, object);
	OUTPUT:
		RETVAL

JSObjectRef
call_as_contructor (object, ...)
		JSObjectRef object
	PREINIT:
		SV *ctx, *tmp;
		JSContextRef cctx;
		JSValueRef *arguments;
		size_t argument_count;
		int i, n_items;
		JSValueRef exception = NULL; /* TODO */
	INIT:
		tmp = ST (items - 1);
		n_items = items;
		if (tmp && SvOK (tmp) && SvROK (tmp) && sv_derived_from (tmp, "JavaScript::JSCore::Context")) {
			n_items--;
			ctx = tmp;
		}
		else {
			ctx = PERL_JSCORE_VALUE_GET_CTX (ST (0));
		}

		cctx = SvJSContextRef (ctx);

		arguments = (JSValueRef *)malloc (sizeof (JSValueRef) * n_items - 1);
		argument_count = n_items - 1;

		for (i = 1; i < n_items; i++) {
			arguments[i - 1] = SvJSValueRef (ST (i));
		}
	CODE:
		RETVAL = JSObjectCallAsConstructor (cctx, object, argument_count, arguments, &exception);
	POSTCALL:
		if (exception) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		free (arguments);
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx);

void
get_properties (object, ctx=NULL)
		JSObjectRef object
		JSContextRef ctx
	PREINIT:
		JSPropertyNameArrayRef props;
		size_t n_props, i;
	INIT:
		if (!ctx) {
			ctx = PERL_JSCORE_VALUE_GET_CCTX (ST (0));
		}
	CODE:
		props = JSObjectCopyPropertyNames (ctx, object);
		n_props = JSPropertyNameArrayGetCount (props);

		EXTEND (sp, n_props);

		for (i = 0; i <= n_props; i++) {
			char *buf;
			size_t buf_size, size;
			JSStringRef prop_name;

			prop_name = JSPropertyNameArrayGetNameAtIndex (props, i);
			buf_size = JSStringGetMaximumUTF8CStringSize (prop_name);
			buf = (char *)malloc (buf_size);

			size = JSStringGetUTF8CString (prop_name, buf, buf_size);
			PUSHs (sv_2mortal (newSVpv (buf, size)));
		}

		XSRETURN (n_props);

void
DESTROY (object)
		JSValueRef object
	CODE:
		warn ("DESTROY 0x%x (0x%x)", (unsigned int)object, (unsigned int)ST (0));
		JSValueUnprotect (PERL_JSCORE_VALUE_GET_CCTX (ST (0)), object);
		warn ("ctx: 0x%x", (unsigned int)PERL_JSCORE_VALUE_GET_CCTX (ST (0)));
		JSGarbageCollect (PERL_JSCORE_VALUE_GET_CCTX (ST (0)));

BOOT:
	perl_jscore_prepend_isa ("JavaScript::JSCore::Object", "JavaScript::JSCore::Value");
