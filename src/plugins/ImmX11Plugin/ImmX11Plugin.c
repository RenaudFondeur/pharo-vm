/* Automatically generated by
	SmartSyntaxPluginCodeGenerator VMMaker.oscog-eem.2347 uuid: 062614a7-e3da-4b30-997a-9568911b9ff5
   from
	ImmX11Plugin VMMaker.oscog-eem.2347 uuid: 062614a7-e3da-4b30-997a-9568911b9ff5
 */
static char __buildInfo[] = "ImmX11Plugin VMMaker.oscog-eem.2347 uuid: 062614a7-e3da-4b30-997a-9568911b9ff5 " __DATE__ ;



#include "config.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <locale.h>

/* Default EXPORT macro that does nothing (see comment in sq.h): */
#define EXPORT(returnType) returnType

/* Do not include the entire sq.h file but just those parts needed. */
#include "sqConfig.h"			/* Configuration options */
#include "sqVirtualMachine.h"	/*  The virtual machine proxy definition */
#include "sqPlatformSpecific.h"	/* Platform specific definitions */

#define true 1
#define false 0
#define null 0  /* using 'null' because nil is predefined in Think C */
#ifdef SQUEAK_BUILTIN_PLUGIN
# undef EXPORT
# define EXPORT(returnType) static returnType
#endif

#include "sqUnixMain.h"
#include "sqUnixCharConv.h"
extern char *setLocale(char *, size_t);
extern int setCompositionWindowPosition(int, int);
extern int setCompositionFocus(int);
#include "sqMemoryAccess.h"


/*** Function Prototypes ***/
EXPORT(const char*) getModuleName(void);
EXPORT(sqInt) initialiseModule(void);
EXPORT(sqInt) primGetEncoding(void);
EXPORT(sqInt) primGetLocale(void);
EXPORT(sqInt) primGetLocaleEncoding(void);
EXPORT(sqInt) primGetPathEnc(void);
EXPORT(sqInt) primGetTextEnc(void);
EXPORT(sqInt) primGetXWinEnc(void);
EXPORT(sqInt) primIsTextEncUTF8(void);
EXPORT(sqInt) primSetCompositionFocus(void);
EXPORT(sqInt) primSetCompositionWindowPosition(void);
EXPORT(sqInt) primSetEncodingToLocale(void);
EXPORT(sqInt) primSetEncoding(sqInt encoding);
EXPORT(sqInt) primSetLocaleEncoding(sqInt encoding);
EXPORT(sqInt) primSetLocale(sqInt locale);
EXPORT(sqInt) primSetPathEncToLocale(void);
EXPORT(sqInt) primSetPathEnc(sqInt encoding);
EXPORT(sqInt) primSetTextEncToLocale(void);
EXPORT(sqInt) primSetTextEncUTF8(void);
EXPORT(sqInt) primSetTextEnc(sqInt encoding);
EXPORT(sqInt) primSetXWinEncToLocale(void);
EXPORT(sqInt) primSetXWinEnc(sqInt encoding);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);
EXPORT(sqInt) shutdownModule(void);
static sqInt sqAssert(sqInt aBool);


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
static void * (*arrayValueOf)(sqInt oop);
static sqInt (*booleanValueOf)(sqInt obj);
static sqInt (*classString)(void);
static sqInt (*failed)(void);
static sqInt (*falseObject)(void);
static void * (*firstIndexableField)(sqInt oop);
static sqInt (*instantiateClassindexableSize)(sqInt classPointer, sqInt size);
static sqInt (*nilObject)(void);
static sqInt (*popthenPush)(sqInt nItems, sqInt oop);
static sqInt (*primitiveFail)(void);
static sqInt (*stSizeOf)(sqInt oop);
static sqInt (*stackIntegerValue)(sqInt offset);
static sqInt (*stackValue)(sqInt offset);
static sqInt (*trueObject)(void);
#else /* !defined(SQUEAK_BUILTIN_PLUGIN) */
extern void * arrayValueOf(sqInt oop);
extern sqInt booleanValueOf(sqInt obj);
extern sqInt classString(void);
extern sqInt failed(void);
extern sqInt falseObject(void);
extern void * firstIndexableField(sqInt oop);
extern sqInt instantiateClassindexableSize(sqInt classPointer, sqInt size);
extern sqInt nilObject(void);
extern sqInt popthenPush(sqInt nItems, sqInt oop);
extern sqInt primitiveFail(void);
extern sqInt stSizeOf(sqInt oop);
extern sqInt stackIntegerValue(sqInt offset);
extern sqInt stackValue(sqInt offset);
extern sqInt trueObject(void);
extern
#endif
struct VirtualMachine* interpreterProxy;
static const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"ImmX11Plugin VMMaker.oscog-eem.2347 (i)"
#else
	"ImmX11Plugin VMMaker.oscog-eem.2347 (e)"
#endif
;



/*	Note: This is hardcoded so it can be run from Squeak.
	The module name is used for validating a module *after*
	it is loaded to check if it does really contain the module
	we're thinking it contains. This is important! */

	/* InterpreterPlugin>>#getModuleName */
EXPORT(const char*)
getModuleName(void)
{
	return moduleName;
}

	/* ImmX11Plugin>>#initialiseModule */
EXPORT(sqInt)
initialiseModule(void)
{
	return 1;
}

	/* ImmX11Plugin>>#primGetEncoding */
EXPORT(sqInt)
primGetEncoding(void)
{
	char *array;
	int len;
	sqInt ret;

	len = strlen(sqTextEncoding);
	ret = instantiateClassindexableSize(classString(), len);
	array = ((char *) (firstIndexableField(ret)));
	strncpy(array, (char *)sqTextEncoding, len);
	return ret;
}

	/* ImmX11Plugin>>#primGetLocale */
EXPORT(sqInt)
primGetLocale(void)
{
	char *array;
	int len;
	char *locale;
	sqInt ret;

	locale = setlocale(LC_CTYPE, "");
	if (locale) {
		len = strlen(locale);
		ret = instantiateClassindexableSize(classString(), len);
		array = ((char *) (firstIndexableField(ret)));
		strncpy(array, (char *)locale, len);
	}
	else {
		ret = nilObject();
	}
	return ret;
}

	/* ImmX11Plugin>>#primGetLocaleEncoding */
EXPORT(sqInt)
primGetLocaleEncoding(void)
{
	char *array;
	int len;
	sqInt ret;

	if ((int) localeEncoding) {
		len = strlen(localeEncoding);
		ret = instantiateClassindexableSize(classString(), len);
		array = ((char *) (firstIndexableField(ret)));
		strncpy(array, (char *)localeEncoding, len);
	}
	else {
		ret = nilObject();
	}
	return ret;
}

	/* ImmX11Plugin>>#primGetPathEnc */
EXPORT(sqInt)
primGetPathEnc(void)
{
	char *array;
	int len;
	sqInt ret;

	len = strlen(uxPathEncoding);
	ret = instantiateClassindexableSize(classString(), len);
	array = ((char *) (firstIndexableField(ret)));
	strncpy(array, (char *)uxPathEncoding, len);
	return ret;
}

	/* ImmX11Plugin>>#primGetTextEnc */
EXPORT(sqInt)
primGetTextEnc(void)
{
	char *array;
	int len;
	sqInt ret;

	len = strlen(uxTextEncoding);
	ret = instantiateClassindexableSize(classString(), len);
	array = ((char *) (firstIndexableField(ret)));
	strncpy(array, (char *)uxTextEncoding, len);
	return ret;
}

	/* ImmX11Plugin>>#primGetXWinEnc */
EXPORT(sqInt)
primGetXWinEnc(void)
{
	char *array;
	int len;
	sqInt ret;

	len = strlen(uxXWinEncoding);
	ret = instantiateClassindexableSize(classString(), len);
	array = ((char *) (firstIndexableField(ret)));
	strncpy(array, (char *)uxXWinEncoding, len);
	return ret;
}

	/* ImmX11Plugin>>#primIsTextEncUTF8 */
EXPORT(sqInt)
primIsTextEncUTF8(void)
{
	sqInt _return_value;

	_return_value = (((textEncodingUTF8)) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}

	/* ImmX11Plugin>>#primSetCompositionFocus: */
EXPORT(sqInt)
primSetCompositionFocus(void)
{
	sqInt bool;
	sqInt ret;
	sqInt _return_value;

	bool = booleanValueOf(stackValue(0));
	if (failed()) {
		return null;
	}
	ret = setCompositionFocus(bool);
	if (ret == 0) {
		primitiveFail();
		return null;
	}
	if (failed()) {
		return null;
	}
	_return_value = ((ret) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(2, _return_value);
	return null;
}

	/* ImmX11Plugin>>#primSetCompositionWindowPositionX:y: */
EXPORT(sqInt)
primSetCompositionWindowPosition(void)
{
	sqInt ret;
	sqInt x;
	sqInt y;
	sqInt _return_value;

	x = stackIntegerValue(1);
	y = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	ret = setCompositionWindowPosition(x, y);
	if (ret == 0) {
		primitiveFail();
		return null;
	}
	if (failed()) {
		return null;
	}
	_return_value = ((ret) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(3, _return_value);
	return null;
}

	/* ImmX11Plugin>>#primSetEncodingToLocale */
EXPORT(sqInt)
primSetEncodingToLocale(void)
{
	sqInt ret;

	if ((int) localeEncoding) {
		sqTextEncoding = (void *)localeEncoding;
		ret = trueObject();
	}
	else {
		ret = falseObject();
	}
	if (failed()) {
		return null;
	}
	popthenPush(1, ret);
	return null;
}

	/* ImmX11Plugin>>#primSetEncoding: */
EXPORT(sqInt)
primSetEncoding(sqInt encoding)
{
	size_t len;
	char *name;

	len = stSizeOf(encoding);
	name = ((char *) (firstIndexableField(encoding)));
	setNEncoding(&sqTextEncoding, name, len);
	return encoding;
}

	/* ImmX11Plugin>>#primSetLocaleEncoding: */
EXPORT(sqInt)
primSetLocaleEncoding(sqInt encoding)
{
	size_t len;
	char *name;

	len = stSizeOf(encoding);
	name = ((char *) (firstIndexableField(encoding)));
	setNEncoding(&localeEncoding, name, len);
	sqTextEncoding= uxTextEncoding= uxPathEncoding= uxXWinEncoding= localeEncoding;
	return encoding;
}

	/* ImmX11Plugin>>#primSetLocale: */
EXPORT(sqInt)
primSetLocale(sqInt locale)
{
	char *array;
	size_t len;
	char *name;
	sqInt ret;

	len = stSizeOf(locale);
	name = ((char *) (arrayValueOf(locale)));
	name = setLocale(name, len);
	if ((int) name) {
		len = strlen(name);
		ret = instantiateClassindexableSize(classString(), len);
		array = ((char *) (firstIndexableField(ret)));
		strncpy(array, (char *)name, len);
		return ret;
	}
	else {
		return nilObject();
	}
}

	/* ImmX11Plugin>>#primSetPathEncToLocale */
EXPORT(sqInt)
primSetPathEncToLocale(void)
{
	sqInt ret;

	if ((int) localeEncoding) {
		uxPathEncoding = (void *)localeEncoding;
		ret = trueObject();
	}
	else {
		ret = falseObject();
	}
	if (failed()) {
		return null;
	}
	popthenPush(1, ret);
	return null;
}

	/* ImmX11Plugin>>#primSetPathEnc: */
EXPORT(sqInt)
primSetPathEnc(sqInt encoding)
{
	size_t len;
	char *name;

	len = stSizeOf(encoding);
	name = ((char *) (firstIndexableField(encoding)));
	setNEncoding(&uxPathEncoding, name, len);
	return encoding;
}

	/* ImmX11Plugin>>#primSetTextEncToLocale */
EXPORT(sqInt)
primSetTextEncToLocale(void)
{
	sqInt ret;

	if ((int) localeEncoding) {
		uxTextEncoding = (void *)localeEncoding;
		ret = trueObject();
	}
	else {
		ret = falseObject();
	}
	if (failed()) {
		return null;
	}
	popthenPush(1, ret);
	return null;
}

	/* ImmX11Plugin>>#primSetTextEncUTF8: */
EXPORT(sqInt)
primSetTextEncUTF8(void)
{
	sqInt bool;
	sqInt _return_value;

	bool = booleanValueOf(stackValue(0));
	if (failed()) {
		return null;
	}
	textEncodingUTF8 = bool;
	if (failed()) {
		return null;
	}
	_return_value = ((bool) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(2, _return_value);
	return null;
}

	/* ImmX11Plugin>>#primSetTextEnc: */
EXPORT(sqInt)
primSetTextEnc(sqInt encoding)
{
	size_t len;
	char *name;

	len = stSizeOf(encoding);
	name = ((char *) (firstIndexableField(encoding)));
	setNEncoding(&uxTextEncoding, name, len);
	return encoding;
}

	/* ImmX11Plugin>>#primSetXWinEncToLocale */
EXPORT(sqInt)
primSetXWinEncToLocale(void)
{
	sqInt ret;

	if ((int) localeEncoding) {
		uxXWinEncoding = (void *)localeEncoding;
		ret = trueObject();
	}
	else {
		ret = falseObject();
	}
	if (failed()) {
		return null;
	}
	popthenPush(1, ret);
	return null;
}

	/* ImmX11Plugin>>#primSetXWinEnc: */
EXPORT(sqInt)
primSetXWinEnc(sqInt encoding)
{
	size_t len;
	char *name;

	len = stSizeOf(encoding);
	name = ((char *) (firstIndexableField(encoding)));
	setNEncoding(&uxXWinEncoding, name, len);
	return encoding;
}


/*	Note: This is coded so that it can be run in Squeak. */

	/* InterpreterPlugin>>#setInterpreter: */
EXPORT(sqInt)
setInterpreter(struct VirtualMachine*anInterpreter)
{
	sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));
	if (ok) {
		
#if !defined(SQUEAK_BUILTIN_PLUGIN)
		arrayValueOf = interpreterProxy->arrayValueOf;
		booleanValueOf = interpreterProxy->booleanValueOf;
		classString = interpreterProxy->classString;
		failed = interpreterProxy->failed;
		falseObject = interpreterProxy->falseObject;
		firstIndexableField = interpreterProxy->firstIndexableField;
		instantiateClassindexableSize = interpreterProxy->instantiateClassindexableSize;
		nilObject = interpreterProxy->nilObject;
		popthenPush = interpreterProxy->popthenPush;
		primitiveFail = interpreterProxy->primitiveFail;
		stSizeOf = interpreterProxy->stSizeOf;
		stackIntegerValue = interpreterProxy->stackIntegerValue;
		stackValue = interpreterProxy->stackValue;
		trueObject = interpreterProxy->trueObject;
#endif /* !defined(SQUEAK_BUILTIN_PLUGIN) */
	}
	return ok;
}

	/* ImmX11Plugin>>#shutdownModule */
EXPORT(sqInt)
shutdownModule(void)
{
	return 1;
}

	/* SmartSyntaxInterpreterPlugin>>#sqAssert: */
static sqInt
sqAssert(sqInt aBool)
{
	/* missing DebugCode */;
	return aBool;
}


#ifdef SQUEAK_BUILTIN_PLUGIN

static char _m[] = "ImmX11Plugin";
void* ImmX11Plugin_exports[][3] = {
	{(void*)_m, "getModuleName", (void*)getModuleName},
	{(void*)_m, "initialiseModule", (void*)initialiseModule},
	{(void*)_m, "primGetEncoding\000\377", (void*)primGetEncoding},
	{(void*)_m, "primGetLocale\000\377", (void*)primGetLocale},
	{(void*)_m, "primGetLocaleEncoding\000\377", (void*)primGetLocaleEncoding},
	{(void*)_m, "primGetPathEnc\000\377", (void*)primGetPathEnc},
	{(void*)_m, "primGetTextEnc\000\377", (void*)primGetTextEnc},
	{(void*)_m, "primGetXWinEnc\000\377", (void*)primGetXWinEnc},
	{(void*)_m, "primIsTextEncUTF8\000\377", (void*)primIsTextEncUTF8},
	{(void*)_m, "primSetCompositionFocus\000\377", (void*)primSetCompositionFocus},
	{(void*)_m, "primSetCompositionWindowPosition\000\000", (void*)primSetCompositionWindowPosition},
	{(void*)_m, "primSetEncodingToLocale\000\377", (void*)primSetEncodingToLocale},
	{(void*)_m, "primSetEncoding", (void*)primSetEncoding},
	{(void*)_m, "primSetLocaleEncoding", (void*)primSetLocaleEncoding},
	{(void*)_m, "primSetLocale", (void*)primSetLocale},
	{(void*)_m, "primSetPathEncToLocale\000\377", (void*)primSetPathEncToLocale},
	{(void*)_m, "primSetPathEnc", (void*)primSetPathEnc},
	{(void*)_m, "primSetTextEncToLocale\000\377", (void*)primSetTextEncToLocale},
	{(void*)_m, "primSetTextEncUTF8\000\377", (void*)primSetTextEncUTF8},
	{(void*)_m, "primSetTextEnc", (void*)primSetTextEnc},
	{(void*)_m, "primSetXWinEncToLocale\000\377", (void*)primSetXWinEncToLocale},
	{(void*)_m, "primSetXWinEnc", (void*)primSetXWinEnc},
	{(void*)_m, "setInterpreter", (void*)setInterpreter},
	{(void*)_m, "shutdownModule\000\377", (void*)shutdownModule},
	{NULL, NULL, NULL}
};

#else /* ifdef SQ_BUILTIN_PLUGIN */

signed char primSetCompositionWindowPositionAccessorDepth = 0;

#endif /* ifdef SQ_BUILTIN_PLUGIN */
