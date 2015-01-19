#!/bin/sh
#
# $Id: locales.sh,v 1.1.1.1 2006/05/13 10:47:39 evaleto Exp $
#

# The default language/keyboard to use. This CANNOT be autoprobed.
# Most of these variables will be used to generate the KDE defaults
# and will be inserted into /etc/sysconfig/* below.


export HOME="/root"
case "$LANGUAGE" in
    de)
	COUNTRY="de"
	LANG="de_DE@euro"
	KEYTABLE="de-latin1-nodeadkeys"
	KEYTABLEFILE="i386/qwertz/de.kmap.gz"
	XKEYBOARD="de"
	KDEKEYBOARD="de"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,fr"
	TZ="Europe/Berlin"
	;;
# BE version
    be)
	LANGUAGE="be"
	COUNTRY="be"
	LANG="C" # used to be "be", but thats Belgarian, not belgian
	KEYTABLE="be-latin1"
	KEYTABLEFILE="i386/azerty/be-latin1.kmap.gz"
	XKEYBOARD="be"
	KDEKEYBOARD="be"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	TZ="Europe/Brussels"
	;;
    bg)
	LANGUAGE="bg"
	COUNTRY="bg"
	LANG="bg_BG"
	KEYTABLE="bg"
	KEYTABLEFILE="i386/qwerty/bg.kmap.gz"
	XKEYBOARD="bg"
	KDEKEYBOARD="bg"
	CHARSET="microsoft-cp1251"
 # Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	TZ="Europe/Sofia"
;;
# Swiss version (basically de with some modifications)
    ch)
	LANGUAGE="de"
	COUNTRY="ch"
	LANG="de_CH"
	KEYTABLE="sg-latin1"
	KEYTABLEFILE="i386/qwertz/fr_CH.kmap.gz"
	XKEYBOARD="de(CH)"
	KDEKEYBOARD="de_CH"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,us,fr"
	TZ="Europe/Zurich"
	;;
    cn)
# Simplified Chinese version
	COUNTRY="cn"
	LANG="zh_CN.GB2312"
	KEYTABLE="us"
	KEYTABLEFILE="sun/sunt5-us-cz.kmap.gz"
	XKEYBOARD="us"
	KDEKEYBOARD="us"
	CHARSET="gb2312.1980-0"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	XMODIFIERS="@im=Chinput"
	TZ="Asia/Shanghai"
	;;
# Czech version
    cs|cz)
	LANGUAGE="cs"
	COUNTRY="cs"
	LANG="cs_CZ"
	KEYTABLE="cz-lat2"
	KEYTABLEFILE="i386/qwerty/cz-us-qwerty.kmap.gz"
	XKEYBOARD="cs"
	KDEKEYBOARD="cs"
	CHARSET="iso8859-2"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	TZ="Europe/Prague"
	;;
    dk|da)
# Dansk version
	COUNTRY="dk"
	LANG="da_DK"
# Workaround: "dk" broken in gettext, use da:da_DK
	LANGUAGE="da:da_DK"
# Keytable "dk" is correct.
	KEYTABLE="dk"
	KEYTABLEFILE="i386/qwerty/dk.kmap.gz"
	XKEYBOARD="dk"
	KDEKEYBOARD="dk"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="dk,de,us,fr"
	TZ="Europe/Copenhagen"
	;;
# Greek version
    el)
	LANGUAGE="el"
	COUNTRY="gr"
	LANG="el_GR"
	KEYTABLE="gr-pc"
	KEYTABLEFILE="i386/qwerty/gr-pc.kmap.gz"
	XKEYBOARD="el"
	KDEKEYBOARD="el"
	CHARSET="iso8859-7"
# Additional KDE Keyboards
	KDEKEYBOARDS="el,us"
	;;
    es)
# Spanish version
	COUNTRY="es"
	LANG="es_ES@euro"
	KEYTABLE="es"
	KEYTABLEFILE="i386/qwerty/es.kmap.gz"
	XKEYBOARD="es"
	KDEKEYBOARD="es"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,us,fr"
	TZ="Europe/Madrid"
	;;
    fi)
# finnish version, though we may not have the kde-i18n files
	COUNTRY="fi"
	LANG="fi_FI@euro"
	KEYTABLE="fi"
	KEYTABLEFILE="i386/qwerty/fi.kmap.gz"
	XKEYBOARD="fi"
	KDEKEYBOARD="fi"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="us"
	TZ="Europe/Helsinki"
	;;
    fr)
# french version
	COUNTRY="fr"
	LANG="fr_FR@euro"
	KEYTABLE="fr"
	KEYTABLEFILE="i386/azerty/fr.kmap.gz"
	XKEYBOARD="fr"
	KDEKEYBOARD="fr"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,us"
	;;
    gl)
# galician version
	COUNTRY="es"
	LANG="gl_ES"
	KEYTABLE="es"
	KEYTABLEFILE="i386/qwerty/es.kmap.gz"
	XKEYBOARD="es"
	KDEKEYBOARD="es"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="es"
	;;
    he|il)
# Hebrew version
	LANGUAGE="he"
	COUNTRY="il"
	LANG="he_IL"
	KEYTABLE="us"
	KEYTABLEFILE="i386/qwerty/hebrew.kmap.gz"
	XKEYBOARD="us"
	KDEKEYBOARD="il"
	CHARSET="iso8859-8"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,fr,de"
	TZ="Asia/Jerusalem"
	;;
    it)
# italian version
	COUNTRY="it"
	LANG="it_IT@euro"
	KEYTABLE="it"
	KEYTABLEFILE="i386/qwerty/it.kmap.gz"
	XKEYBOARD="it"
	KDEKEYBOARD="it"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="fr,us,de"
	TZ="Europe/Rome"
	;;

    ja)
# (limited) japanese version
	COUNTRY="jp"
	LANG="ja_JP"
	LANGUAGE="ja"
	KEYTABLE="us"
	KEYTABLEFILE="sun/sunt5-ja.kmap.gz"
	XKEYBOARD="us"
	KDEKEYBOARD="us"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="fr,us,de"
	TZ="Asia/Tokyo"
	;;
    lv)
# Latvian version
	LANGUAGE="lv"  # ISO 639
	COUNTRY="lv"
	LANG="lv_LV"
	KEYTABLE="lv-latin7"
	KEYTABLEFILE="i386/qwerty/lv-latin7.kmap.gz"
	XKEYBOARD="lv" 
	KDEKEYBOARD="lv" 
	CHARSET="iso8859-13"
	KDEKEYBOARDS="ee,lt,en_US,ru" # Additional KDE Keyboards 
	;;
    lt)
# Lithuanian version
	LANGUAGE="lt"  # ISO 639
	COUNTRY="lt" 
	LANG="lt_LT" 
	KEYTABLE="lt"
	KEYTABLEFILE="i386/qwerty/lt.kmap.gz" 
	XKEYBOARD="lt,us,ru"
	KDEKEYBOARD="lt" 
	CHARSET="iso8859-13"
	KDEKEYBOARDS="ee,lv,en_US,ru" # Additional KDE Keyboards 
	;;
    nl)
# netherland version
	COUNTRY="nl"
	LANG="nl_NL@euro"
	KEYTABLE="us"
	KEYTABLEFILE="i386/qwerty/nl.kmap.gz"
	XKEYBOARD="us,nl"
	KDEKEYBOARD="us"
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="nl,de,fr"
	TZ="Europe/Amsterdam" # Hup holland hup! :D
	;;
    pl)
# Polish version
	COUNTRY="pl"
	LANG="pl_PL"
	KEYTABLE="pl"
	KEYTABLEFILE="i386/qwerty/pl.kmap.gz"
	XKEYBOARD="pl"
	KDEKEYBOARD="pl"
	CHARSET="iso8859-2"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,us,fr"
	TZ="Europe/Warsaw"
	;;
    pt)
# Portuguese version
        LANGUAGE="pt_BR:pt:pt_PT"
        COUNTRY="br"
        LANG="pt_BR.UTF-8"
        KEYTABLE="us"
        XKEYBOARD="br" 
        KDEKEYBOARD="abnt2"
        CHARSET="iso8859-1"
# Additional KDE Keyboards
        KDEKEYBOARDS="us_intl"
        TZ="America/Brasilia"
    ;;
    ru)
# Russian version
	COUNTRY="ru"
	LANG="ru_RU.KOI8-R"
	KEYTABLE="ru"
	KEYTABLEFILE="i386/qwerty/ru.kmap.gz"
	XKEYBOARD="ru"
	KDEKEYBOARD="ru"
	CHARSET="koi8-r"
	CONSOLEFONT="Cyr_a8x16"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,us,fr"
	TZ="Europe/Moscow"
	;;
    sf)
# Swiss french version
#	LANGUAGE="fr_CH"
	COUNTRY="ch"
	LANG="fr_CH"
	KEYTABLE="fr_CH-latin1"
	KEYTABLEFILE="i386/qwertz/fr_CH-latin1.kmap.gz"
	XKEYBOARD="fr(CH)"
	KDEKEYBOARD="fr_CH"
	CONSOLEFONT="lat0-16"
  CHARSET_MAP="iso15"
#I'm not sure with that
	CHARSET="iso8859-15"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,us,it"
	TZ="Europe/Zurich"
	;;
    sk)
# Slovak version (guessed)
	COUNTRY="sk"
	LANG="sk"
	KEYTABLE="sk-qwerty"
	KEYTABLEFILE="i386/qwerty/sk-qwerty.kmap.gz"
	XKEYBOARD="sk"
	KDEKEYBOARD="sk"
	CHARSET="iso8859-2"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	;;
# Slovenian version/keyboard, Fabians knoppix-autoconfig_i18n.patch from 2003-07-26
    sl)
	LANGUAGE="sl"
	COUNTRY="si"
	LANG="sl_SI"
	KEYTABLE="slovene"
	KEYTABLEFILE="i386/qwertz/slovene.kmap.gz"
	XKEYBOARD="sl,us"
	KDEKEYBOARD="si"
	CHARSET="iso8859-2"
	CONSOLEFONT="iso02g"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	TZ="Europe/Ljubljana"
	;;
    tr)
# Turkish version (guessed)
	COUNTRY="tr"
	LANG="tr_TR"
	KEYTABLE="tr_q-latin5"
	KEYTABLEFILE="sun/sunt5-trqalt.kmap.gz"
	XKEYBOARD="tr"
	KDEKEYBOARD="tr"
	CHARSET="iso8859-9"
# Additional KDE Keyboards
	KDEKEYBOARDS="us,de,fr"
	TZ="Europe/Istanbul"
	;;
    tw)
# Traditional chinese version (thanks to Chung-Yen Chang)
	COUNTRY="tw"
	LANG="zh_TW.Big5"
	LANGUAGE="zh_TW.Big5"
	KEYTABLE="us"
	KEYTABLEFILE="sun/sunt5-us-cz.kmap.gz"
	XKEYBOARD="us"
	KDEKEYBOARD="us"
# CHARSET="big5-0"
	CHARSET="iso8859-1"
# Additional KDE Keyboards
	KDEKEYBOARDS="us"
	XMODIFIERS="@im=xcin"
	TZ="Asia/Taipei"
	;;
    uk)
# british version
	LANGUAGE="en_GB"
	COUNTRY="uk"
	LANG="en_GB"
	KEYTABLE="uk"
	KEYTABLEFILE="i386/qwerty/uk.kmap.gz"
	XKEYBOARD="uk"
	KDEKEYBOARD="gb"
	CHARSET="iso8859-1"
# Additional KDE Keyboards
	KDEKEYBOARDS="us"
	TZ="Europe/London"
	;;
    *)
# US version
	LANGUAGE="us"
	COUNTRY="us"
	LANG="C"
	KEYTABLE="us"
	KEYTABLEFILE="i386/qwerty/us.kmap.gz"
	XKEYBOARD="us"
	KDEKEYBOARD="us"
	CHARSET="iso8859-1"
# Additional KDE Keyboards
	KDEKEYBOARDS="de,fr"
	TZ="America/New_York"
    ;;
    
esac
# Allow keyboard override by boot commandline
KKEYBOARD="$(getbootparam keyboard 2>/dev/null)"
[ -n "$KKEYBOARD" ] && KEYTABLE="$KKEYBOARD"
KXKEYBOARD="$(getbootparam xkeyboard 2>/dev/null)"
if [ -n "$KXKEYBOARD" ]; then
    XKEYBOARD="$KXKEYBOARD"
    KDEKEYBOARD="$KXKEYBOARD"
elif [ -n "$KKEYBOARD" ]; then
    XKEYBOARD="$KKEYBOARD"
    KDEKEYBOARD="$KKEYBOARD"
fi
