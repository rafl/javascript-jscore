#include "perl_jscore.h"

SV *
perl_jscore_ptr_to_obj (void *ptr, const char *klass) {
	SV *obj, *sv;
	HV *stash;

	obj = (SV *)newHV ();
	sv_magic (obj, 0, PERL_MAGIC_ext, (const char *)ptr, 0);
	sv = newRV_noinc (obj);
	stash = gv_stashpv (klass, 0);
	sv_bless (sv, stash);

	return sv;
}

void *
perl_jscore_obj_to_ptr (SV *obj, const char *klass) {
	MAGIC *mg;

	if (!obj || !SvOK (obj) || !SvROK (obj) || (SvTYPE (SvRV (obj)) != SVt_PVHV)) {
		croak ("scalar is not a hash reference");
	}

	if (!sv_derived_from (obj, klass)) {
		croak ("object isn't an instance of %s", klass);
	}

	if (!(mg = mg_find (SvRV (obj), PERL_MAGIC_ext))) {
		croak ("failed to find magic");
	}

	return (void *)mg->mg_ptr;
}

void
perl_jscore_prepend_isa (const char *child, const char *parent) {
	char *child_isa_full;
	AV *isa;

	child_isa_full = (char *)malloc (sizeof (char) * (strlen (child) + 6));
	strcpy (child_isa_full, child);
	strcat (child_isa_full, "::ISA");

	isa = get_av (child_isa_full, TRUE);
	free (child_isa_full);

	av_unshift (isa, 1);
	av_store (isa, 0, newSVpv (parent, 0));
}

SV *
perl_jscore_value_get_ctx (SV *val) {
	SV **he;

	he = hv_fetchs ((HV *)SvRV (val), "context", 0);

	if (!he || !*he) {
		croak ("failed to get context from value");
	}

	return *he;
}

JSPropertyAttributes
perl_jscore_sv_to_property_attributes (SV *sv) {
	AV *av;
	I32 i;
	JSPropertyAttributes ret = kJSPropertyAttributeNone;

	if (!sv || !SvOK (sv) || !SvROK (sv) || (SvTYPE (SvRV (sv)) != SVt_PVAV)) {
		return kJSPropertyAttributeNone;
	}

	av = (AV *)SvRV (sv);

	for (i = 0; i < av_len (av); i++) {
		char *flag_str;
		SV **ae;

		ae = av_fetch (av, i, 0);

		if (!ae || !*ae) {
			croak ("failed to fetch array element");
		}

		flag_str = SvPV_nolen (*ae);

		if (strEQ (flag_str, "read-only")) {
			ret |= kJSPropertyAttributeReadOnly;
		} else if (strEQ (flag_str, "dont-enum")) {
			ret |= kJSPropertyAttributeDontEnum;
		} else if (strEQ (flag_str, "dont-delete")) {
			ret |= kJSPropertyAttributeDontDelete;
		} else {
			croak ("invalid property attributes");
		}
	}

	return ret;
}

/*
JSClassDefinition
SvJSClassDefinition (SV *sv) {
	JSClassDefinition ret;

	if (!sv || !SvOK (sv) || !SvROK (sv) || (SvTYPE (SvRV (sv)) != SVt_PVHV)) {
		croak ("class definition needs to be a hash reference");
	}

	ret = kJSClassDefinitionEmpty;

#define INSTALL_PERL_CALLBACK(field, jscore_field) \
	{ \
		SV **he; \
		he = hv_fetch ((HV *)SvRV (sv), STRINGIFY(field), sizeof (STRINGIFY(field)), 0); \
		if (he && *he) { \
			if (!SvOK (*he) || !SvROK (*he) || (SvTYPE (SvRV (*he)) != SVt_PVCV)) { \
				croak ("%s needs to be a code reference", STRINGIFY(field)); \
			} \
			ret.jscore_field = perl_jscore_class_cb_##field; \
		} \
	}

	INSTALL_PERL_CALLBACK (initialize, initialize);
	INSTALL_PERL_CALLBACK (finalize, initialize);
	INSTALL_PERL_CALLBACK (has_property, hasProperty);
	INSTALL_PERL_CALLBACK (get_property, getProperty);
	INSTALL_PERL_CALLBACK (set_property, setProperty);
	INSTALL_PERL_CALLBACK (delete_property, deleteProperty);
	INSTALL_PERL_CALLBACK (get_property_names, getPropertyNames);
	INSTALL_PERL_CALLBACK (call_as_function, callAsFunction);
	INSTALL_PERL_CALLBACK (call_as_constructor, callAsConstructor);
	INSTALL_PERL_CALLBACK (has_instance, hasInstance);
	INSTALL_PERL_CALLBACK (convert_to_type, convertToType);

	return ret;
}
*/
