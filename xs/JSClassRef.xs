#include "perl_jscore.h"

typedef struct perl_jsclass_def_St {
	SV *initialize;
	SV *finalize;
	SV *has_property;
	SV *get_property;
	SV *set_property;
	SV *delete_property;
	SV *get_property_names;
	SV *call_as_function;
	SV *call_as_constructor;
	SV *has_instance;
	SV *convert_to_type;
	SV *obj_wrapper;
	SV *ctx_wrapper;
} perl_jsclass_def_t;

typedef enum {
	INITIALIZE,
	FINALIZE,
	HAS_PROPERTY,
	GET_PROPERTY,
	SET_PROPERTY,
	DELETE_PROPERTY,
	GET_PROPERTY_NAMES,
	CALL_AS_FUNCTION,
	CALL_AS_CONSTRUCTOR,
	HAS_INSTANCE,
	CONVERT_TO_TYPE
} perl_jsclass_cb_type_t;

static const struct {
	perl_jsclass_cb_type_t type;
	const char *name;
} callbacks[] = {
	{ INITIALIZE, "initialize" },
	{ FINALIZE, "finalize" },
	{ HAS_PROPERTY, "has_property" },
	{ GET_PROPERTY, "get_property" },
	{ SET_PROPERTY, "set_property" },
	{ DELETE_PROPERTY, "delete_property" },
	{ GET_PROPERTY_NAMES, "get_property_names" },
	{ CALL_AS_FUNCTION, "call_as_function" },
	{ CALL_AS_CONSTRUCTOR, "call_as_constructor" },
	{ HAS_INSTANCE, "has_instance" },
	{ CONVERT_TO_TYPE, "convert_to_type" }
};

static void
initialize_cb (JSContextRef ctx, JSObjectRef obj) {
	int count;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 2);
	PUSHs (defs->ctx_wrapper);
	PUSHs (sv_2mortal (newSVJSObjectTempRef (obj)));
	PUTBACK;

	count = call_sv (defs->initialize, G_VOID|G_DISCARD);

	SPAGAIN;

	if (count != 0) {
		croak ("bug");
	}

	PUTBACK;
	FREETMPS;
	LEAVE;
}

static void
finalize_cb (JSObjectRef obj) {
	int count;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	warn ("finalize 0x%x", (unsigned int)obj);
	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 1);
	PUSHs (defs->obj_wrapper);
	PUTBACK;

	count = call_sv (defs->finalize, G_VOID|G_DISCARD);

	SPAGAIN;

	if (count != 0) {
		croak ("bug");
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	free (defs);
}

static bool
has_property_cb (JSContextRef ctx, JSObjectRef obj, JSStringRef prop_name) {
	bool ret;
	int count;
	char *buf;
	size_t buf_size, size;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	buf_size = JSStringGetMaximumUTF8CStringSize (prop_name);
	buf = (char *)malloc (buf_size);

	size = JSStringGetUTF8CString (prop_name, buf, buf_size);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 3);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUSHs (sv_2mortal (newSVpv (buf, size)));
	PUTBACK;

	free (buf);

	count = call_sv (defs->has_property, G_SCALAR);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	ret = SvTRUE (POPs);

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static JSValueRef
get_property_cb (JSContextRef ctx, JSObjectRef obj, JSStringRef prop_name,
                 JSValueRef *exception) {
	JSValueRef ret;
	SV *err;
	int count;
	char *buf;
	size_t buf_size, size;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	buf_size = JSStringGetMaximumUTF8CStringSize (prop_name);
	buf = (char *)malloc (buf_size);

	size = JSStringGetUTF8CString (prop_name, buf, buf_size);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 3);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUSHs (sv_2mortal (newSVpv (buf, size)));
	PUTBACK;

	free (buf);

	count = call_sv (defs->get_property, G_SCALAR|G_EVAL);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = NULL;
	}
	else {
		ret = SvJSValueRef (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static bool
set_property_cb (JSContextRef ctx, JSObjectRef obj, JSStringRef prop_name,
                 JSValueRef value, JSValueRef *exception) {
	bool ret;
	SV *err;
	int count;
	char *buf;
	size_t buf_size, size;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	buf_size = JSStringGetMaximumUTF8CStringSize (prop_name);
	buf = (char *)malloc (buf_size);

	size = JSStringGetUTF8CString (prop_name, buf, buf_size);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 4);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUSHs (sv_2mortal (newSVpv (buf, size)));
	PUSHs (sv_2mortal (newSVJSValueRef (value)));
	PUTBACK;

	free (buf);

	count = call_sv (defs->set_property, G_SCALAR|G_EVAL);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = false;
	}
	else {
		ret = SvTRUE (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static bool
delete_property_cb (JSContextRef ctx, JSObjectRef obj, JSStringRef prop_name,
                    JSValueRef *exception) {
	bool ret;
	SV *err;
	int count;
	char *buf;
	size_t buf_size, size;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	buf_size = JSStringGetMaximumUTF8CStringSize (prop_name);
	buf = (char *)malloc (buf_size);

	size = JSStringGetUTF8CString (prop_name, buf, buf_size);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 3);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUSHs (sv_2mortal (newSVpv (buf, size)));
	PUTBACK;

	free (buf);

	count = call_sv (defs->delete_property, G_SCALAR|G_EVAL);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = false;
	}
	else {
		ret = SvTRUE (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static void
get_property_names_cb (JSContextRef ctx, JSObjectRef obj,
                       JSPropertyNameAccumulatorRef prop_names) {
	int count;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 2);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUTBACK;

	count = call_sv (defs->get_property_names, G_ARRAY);

	SPAGAIN;

	while (count--) {
		JSPropertyNameAccumulatorAddName (prop_names, JSStringCreateWithUTF8CString (POPp));
	}

	PUTBACK;
	FREETMPS;
	LEAVE;
}

static JSValueRef
call_as_function_cb (JSContextRef ctx, JSObjectRef obj, JSObjectRef this_obj,
                     size_t argument_count, const JSValueRef arguments[],
                     JSValueRef *exception) {
	JSValueRef ret;
	int count, i;
	SV *err;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 3 + argument_count);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUSHs (sv_2mortal (newSVJSObjectRef (this_obj)));

	for (i = 0; i <= argument_count; i++) {
		PUSHs (sv_2mortal (newSVJSValueRef (arguments[i])));
	}

	count = call_sv (defs->call_as_function, G_SCALAR|G_EVAL);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = NULL;
	}
	else {
		ret = SvJSValueRef (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static JSObjectRef
call_as_constructor_cb (JSContextRef ctx, JSObjectRef constructor,
                        size_t argument_count, const JSValueRef arguments[],
                        JSValueRef *exception) {
	JSObjectRef ret;
	int count, i;
	SV *err;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (constructor);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 2 + argument_count);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (constructor)));

	for (i = 0; i <= argument_count; i++) {
		PUSHs (sv_2mortal (newSVJSValueRef (arguments[i])));
	}

	count = call_sv (defs->call_as_function, G_SCALAR|G_EVAL);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = NULL;
	}
	else {
		ret = SvJSObjectRef (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static bool
has_instance_cb (JSContextRef ctx, JSObjectRef constructor,
                 JSValueRef possible_instance, JSValueRef *exception) {
	bool ret;
	int count;
	SV *err;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (constructor);

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 3);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (constructor)));
	PUSHs (sv_2mortal (newSVJSValueRef (possible_instance)));
	PUTBACK;

	count = call_sv (defs->has_instance, G_SCALAR|G_EVAL);

	SPAGAIN;

	if (count != 1) {
		croak ("bug");
	}

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = false;
	}
	else {
		ret = SvTRUE (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

static JSValueRef
convert_to_type_cb (JSContextRef ctx, JSObjectRef obj, JSType type,
                    JSValueRef *exception) {
	JSValueRef ret;
	int count;
	SV *err;
	char *type_str;
	perl_jsclass_def_t *defs = (perl_jsclass_def_t *)JSObjectGetPrivate (obj);

	switch (type) {
		case kJSTypeUndefined:
			type_str = "undefined";
			break;
		case kJSTypeNull:
			type_str = "null";
			break;
		case kJSTypeBoolean:
			type_str = "boolean";
			break;
		case kJSTypeNumber:
			type_str = "number";
			break;
		case kJSTypeString:
			type_str = "string";
			break;
		case kJSTypeObject:
			type_str = "object";
			break;
		default:
			croak ("invalid JS type");
	}

	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (sp);
	EXTEND (sp, 3);
	PUSHs (sv_2mortal (newSVJSContextRef (ctx)));
	PUSHs (sv_2mortal (newSVJSObjectRef (obj)));
	PUSHs (sv_2mortal (newSVpv (type_str, 0)));
	PUTBACK;

	count = call_sv (defs->convert_to_type, G_SCALAR|G_EVAL);

	SPAGAIN;

	err = get_sv ("@", TRUE);
	if (SvTRUE (err)) {
		(void)POPs;
		*exception = SvJSValueRef (err);
		ret = NULL;
	}
	else {
		ret = SvJSValueRef (POPs);
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return ret;
}

MODULE = JavaScript::JSCore::Class	PACKAGE = JavaScript::JSCore::Class

JSClassRef
new (class, definition)
		HV *definition
	PREINIT:
		JSClassDefinition def = kJSClassDefinitionEmpty;
		JSClassAttributes attributes = kJSClassAttributeNone;
		SV **he;
		char *class_name;
		JSClassRef parent_class = NULL;
		int i;
	INIT:
		he = hv_fetchs (definition, "attributes", 0);
		if (he && *he) {
			I32 i;
			AV *av;

			if (!SvOK (*he) || !SvROK (*he) || (SvTYPE (SvRV (*he)) != SVt_PVAV)) {
				croak ("attributes need to be an array reference");
			}

			av = (AV *)SvRV (*he);

			for (i = 0; i < av_len (av); i++) {
				char *attr;
				he = av_fetch (av, i, 0);

				if (!he || !*he) {
					croak ("failed to fetch values from attributes array");
				}

				attr = SvPV_nolen (*he);
				if (strEQ (attr, "no-automatic-prototype")) {
					attributes |= kJSClassAttributeNoAutomaticPrototype;
				}
				else {
					croak ("invalid class attribute %s", attr);
				}
			}
		}

		he = hv_fetchs (definition, "name", 0);
		if (!he || !*he || !SvOK (*he)) {
			croak ("no or invalid class name");
		}

		class_name = SvPV_nolen (*he);

		he = hv_fetchs (definition, "parent_class", 0);
		if (he && *he && SvOK (*he) && SvROK (*he) && (SvTYPE (SvRV (*he)) == SVt_PVHV)
		 && sv_derived_from (*he, "JavaScript::JSCore::Class")) {
			parent_class = SvJSClassRef (*he);
		}

		for (i = 0; i < sizeof (callbacks) / sizeof (callbacks[0]); i++) {
			const char *cb = callbacks[i].name;
			he = hv_fetch (definition, cb, strlen (cb), 0);

			if (!he || !*he) {
				continue;
			}

			if (!SvOK (*he) || !SvROK (*he) || (SvTYPE (SvRV (*he)) != SVt_PVCV)) {
				croak ("%s, if supplied, needs to be a code reference", cb);
			}

			switch (callbacks[i].type) {
				case INITIALIZE:
					def.initialize = initialize_cb;
					break;
				case FINALIZE:
					def.finalize = finalize_cb;
					break;
				case HAS_PROPERTY:
					def.hasProperty = has_property_cb;
					break;
				case GET_PROPERTY:
					def.getProperty = get_property_cb;
					break;
				case SET_PROPERTY:
					def.setProperty = set_property_cb;
					break;
				case DELETE_PROPERTY:
					def.deleteProperty = delete_property_cb;
					break;
				case GET_PROPERTY_NAMES:
					def.getPropertyNames = get_property_names_cb;
					break;
				case CALL_AS_FUNCTION:
					def.callAsFunction = call_as_function_cb;
					break;
				case CALL_AS_CONSTRUCTOR:
					def.callAsConstructor = call_as_constructor_cb;
					break;
				case HAS_INSTANCE:
					def.hasInstance = has_instance_cb;
					break;
				case CONVERT_TO_TYPE:
					def.convertToType = convert_to_type_cb;
					break;
				default:
					croak ("invalid callback type");
			}
		}

		def.version = 0;
		def.attributes = attributes;
		def.className = class_name;
		def.parentClass = parent_class;
		def.staticValues = NULL;
		def.staticFunctions = NULL;
	CODE:
		RETVAL = JSClassCreate (&def);
	OUTPUT:
		RETVAL
	CLEANUP:
		for (i = 0; i < sizeof (callbacks) / sizeof (callbacks[0]); i++) {
			const char *cb = callbacks[i].name;

			he = hv_fetch (definition, cb, strlen (cb), 0);
			if (!he || !*he) {
				continue;
			}

			if (!hv_store ((HV *)SvRV (ST (0)), cb, strlen (cb), newSVsv (*he), 0)) {
				croak ("failed to store callback in hash");
			}
		}

JSObjectRef
create_instance (class, ctx)
		JSClassRef class
		JSContextRef ctx
	PREINIT:
		perl_jsclass_def_t *perl_def;
		int i;
		SV *ctx_sv = ST (1);
	INIT:
		perl_def = (perl_jsclass_def_t *)malloc (sizeof (perl_jsclass_def_t));
		memset (perl_def, 0, sizeof (perl_jsclass_def_t));

		perl_def->ctx_wrapper = ctx_sv;

		for (i = 0; i < sizeof (callbacks) / sizeof (callbacks[0]); i++) {
			SV **he;
			const char *cb = callbacks[i].name;

			he = hv_fetch ((HV *)SvRV (ST (0)), cb, strlen (cb), 0);
			if (!he || !*he) {
				continue;
			}

			switch (callbacks[i].type) {
				case INITIALIZE:
					perl_def->initialize = newSVsv (*he);
					break;
				case FINALIZE:
					perl_def->finalize = newSVsv (*he);
					break;
				case HAS_PROPERTY:
					perl_def->has_property = newSVsv (*he);
					break;
				case GET_PROPERTY:
					perl_def->get_property = newSVsv (*he);
					break;
				case SET_PROPERTY:
					perl_def->set_property = newSVsv (*he);
					break;
				case DELETE_PROPERTY:
					perl_def->delete_property = newSVsv (*he);
					break;
				case GET_PROPERTY_NAMES:
					perl_def->get_property_names = newSVsv (*he);
					break;
				case CALL_AS_FUNCTION:
					perl_def->call_as_function = newSVsv (*he);
					break;
				case CALL_AS_CONSTRUCTOR:
					perl_def->call_as_constructor = newSVsv (*he);
					break;
				case HAS_INSTANCE:
					perl_def->has_instance = newSVsv (*he);
					break;
				case CONVERT_TO_TYPE:
					perl_def->convert_to_type = newSVsv (*he);
					break;
				default:
					croak ("invalid callback type");
			}
		}
	CODE:
		RETVAL = JSObjectMake (ctx, class, (void *)perl_def);
	OUTPUT:
		RETVAL
	CLEANUP:
		JSValueProtect (ctx, (JSValueRef)RETVAL);
		perl_def->obj_wrapper = ST (0);
		PERL_JSCORE_VALUE_STORE_CTX (ST (0), ctx_sv);
