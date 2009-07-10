#include "perl_jscore.h"

MODULE = JavaScript::JSCore::Context	PACKAGE = JavaScript::JSCore::Context

JSObjectRef
get_global_object (ctx)
		JSContextRef ctx
	PREINIT:
		SV *ctx_sv;
	INIT:
		ctx_sv = ST (0);
	CODE:
		RETVAL = JSContextGetGlobalObject (ctx);
	OUTPUT:
		RETVAL
	CLEANUP:
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx_sv);

JSValueRef
evaluate_script (ctx, script, ...)
		JSContextRef ctx
		JSStringRef script
	PREINIT:
		JSObjectRef object = NULL;
		JSStringRef source_url = NULL;
		int starting_line_number = 1;
		JSValueRef exception;
		SV *ctx_sv;
	PREINIT:
		ctx_sv = ST (0);
	CODE:
		switch (items) {
			case 5:
				starting_line_number = SvIV (ST (4));
			case 4:
				source_url = JSStringCreateWithUTF8CString (SvPVutf8_nolen (ST (3)));
			case 3:
				object = SvJSObjectRef (ST (2));
			case 2:
				break;
			default:
				croak ("foo");
		}

		exception = NULL; /* TODO */

		RETVAL = JSEvaluateScript (ctx, script, object, source_url,
		                           starting_line_number, &exception);
	POSTCALL:
		if (RETVAL == NULL) {
			croak ("exception"); /* TODO */
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx_sv);

bool
check_script_syntax (ctx, script, ...)
		JSContextRef ctx
		JSStringRef script
	PREINIT:
		JSStringRef source_url = NULL;
		int starting_line_number = 1;
		JSValueRef exception;
	CODE:
		switch (items) {
			case 4:
				starting_line_number = SvIV (ST (3));
			case 3:
				source_url = JSStringCreateWithUTF8CString (SvPVutf8_nolen (ST (3)));
			case 2:
				break;
			default:
				croak ("foo");
		}

		exception = NULL; /* TODO */

		RETVAL = JSCheckScriptSyntax (ctx, script, source_url,
		                              starting_line_number, &exception);
	POSTCALL:
		if (RETVAL) {
			croak ("syntax error"); /* TODO */
		}
	OUTPUT:
		RETVAL

void
garbage_collect (ctx)
		JSContextRef ctx
	CODE:
		warn ("gc ctx 0x%x", (unsigned int)ctx);
		JSGarbageCollect (ctx);

JSValueRef
create_value (ctx, type, val=NULL)
		JSContextRef ctx
		JSType type
		SV *val
	PREINIT:
		SV *ctx_sv;
	INIT:
		ctx_sv = ST (0);
	CODE:
		switch (type) {
			case kJSTypeUndefined:
				RETVAL = JSValueMakeUndefined (ctx);
				break;
			case kJSTypeNull:
				RETVAL = JSValueMakeNull (ctx);
				break;
			case kJSTypeBoolean:
				RETVAL = JSValueMakeBoolean (ctx, val ? SvTRUE (val) : false);
				break;
			case kJSTypeNumber:
				RETVAL = JSValueMakeNumber (ctx, val ? (double)SvNV (val) : (double)0);
				break;
			case kJSTypeString:
				RETVAL = JSValueMakeString (ctx, JSStringCreateWithUTF8CString (val ? SvPV_nolen (val) : ""));
				break;
			case kJSTypeObject:
				croak ("can't create JS object using create_value");
				break;
		}
	OUTPUT:
		RETVAL
	CLEANUP:
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx_sv);
