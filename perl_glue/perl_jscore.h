#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <JavaScriptCore/JavaScript.h>

#define PERL_JSCORE_CALL_BOOT(name) \
	{ \
		EXTERN_C XS (name); \
		dSP; \
		PUSHMARK (mark); \
		(*name) (aTHX_ cv); \
		PUTBACK; \
	}

#define PERL_JSCORE_VALUE_STORE_CTX(val, ctx_wrapper) \
	{ \
		SvREFCNT_inc (SvRV (ctx_wrapper)); \
		if (!hv_stores ((HV *)SvRV (val), "context", ctx_wrapper)) { \
			croak ("failed to store context object for JSCore Value"); \
		} \
	}

#define PERL_JSCORE_VALUE_GET_CTX(val) (perl_jscore_value_get_ctx (val))
#define PERL_JSCORE_VALUE_GET_CCTX(val) (SvJSContextRef (PERL_JSCORE_VALUE_GET_CTX (val)))

#define SvJSContextRef(sv)       ((JSContextRef)perl_jscore_obj_to_ptr       (sv, "JavaScript::JSCore::Context"))
#define SvJSGlobalContextRef(sv) ((JSGlobalContextRef)perl_jscore_obj_to_ptr (sv, "JavaScript::JSCore::Context::Global"))
#define SvJSValueRef(sv)         ((JSValueRef)perl_jscore_obj_to_ptr         (sv, "JavaScript::JSCore::Value"))
#define SvJSClassRef(sv)         ((JSClassRef)perl_jscore_obj_to_ptr         (sv, "JavaScript::JSCore::Class"))
#define SvJSObjectRef(sv)        ((JSObjectRef)perl_jscore_obj_to_ptr        (sv, "JavaScript::JSCore::Object"))
#define SvPropertyAttributes(sv) (perl_jscore_sv_to_property_attributes (sv))

#define newSVJSContextRef(ptr)       (perl_jscore_ptr_to_obj ((void *)ptr, "JavaScript::JSCore::Context"))
#define newSVJSGlobalContextRef(ptr) (perl_jscore_ptr_to_obj ((void *)ptr, "JavaScript::JSCore::Context::Global"))
#define newSVJSValueRef(ptr)         (perl_jscore_ptr_to_obj ((void *)ptr, "JavaScript::JSCore::Value"))
#define newSVJSClassRef(ptr)         (perl_jscore_ptr_to_obj ((void *)ptr, "JavaScript::JSCore::Class"))
#define newSVJSObjectRef(ptr)        (perl_jscore_ptr_to_obj ((void *)ptr, "JavaScript::JSCore::Object"))
#define newSVJSObjectTempRef(ptr)        (perl_jscore_ptr_to_obj ((void *)ptr, "JavaScript::JSCore::Object::Temp"))

SV *perl_jscore_ptr_to_obj (void *ptr, const char *klass);
void *perl_jscore_obj_to_ptr (SV *obj, const char *klass);

void perl_jscore_prepend_isa (const char *child, const char *parent);

SV *perl_jscore_value_get_ctx (SV *val);

JSPropertyAttributes perl_jscore_sv_to_property_attributes (SV *sv);
