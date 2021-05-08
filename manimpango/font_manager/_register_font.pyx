# Register_Font should provide a Python Wrapper
# by returning the family name once adding it
# to search Path. Other than that the font_path
# should accept `PathLike` objects for example
# `pathlib.Path` instead of just strings.
# Other than that this can be used directly in
# our Stable API.


from pathlib import Path
from pango cimport *

import copy

cpdef bint fc_register_font(str font_path):
    """This function registers the font file using ``fontconfig`` so that
    it is available for use by Pango. On Linux it is aliased to
    :func:`register_font` and on Windows and macOS this would work only when
    using ``fontconfig`` backend.

    Parameters
    ==========
    font_path : :class:`str`
        Relative or absolute path to font file.
    Returns
    =======
    :class:`bool`
            True means it worked without any error.
            False means there was an unknown error
    Examples
    --------
    >>> register_font("/home/roboto.tff")
    True

    Raises
    ------
    AssertionError
        Font is missing.
    """
    a=Path(font_path)
    assert a.exists(), f"font doesn't exist at {a.absolute()}"
    font_path = str(a.absolute())
    font_path_bytes=font_path.encode('utf-8')
    cdef const unsigned char* fontPath = font_path_bytes
    fontAddStatus = FcConfigAppFontAddFile(FcConfigGetCurrent(), fontPath)
    if fontAddStatus:
        return True
    else:
        return False


cpdef bint fc_unregister_font(str font_path):
    """This function unregisters(removes) the font file using
    ``fontconfig``. It is mostly optional to call this.
    Mainly used in tests. On Linux it is aliased to
    :func:`unregister_font` and on Windows and macOS this
    would work only when using ``fontconfig`` backend.

    Parameters
    ==========

    font_path: :class:`str`
        For compatibility with the windows function.

    Returns
    =======
    :class:`bool`
            True means it worked without any error.
            False means there was an unknown error

    """
    FcConfigAppFontClear(NULL)
    return True


IF UNAME_SYSNAME == "Linux":
    register_font = fc_register_font
    unregister_font = fc_unregister_font


ELIF UNAME_SYSNAME == "Windows":
    cpdef bint register_font(str font_path):
        """This function registers the font file using native windows API
        so that it is available for use by Pango.

        Parameters
        ==========
        font_path : :class:`str`
            Relative or absolute path to font file.
        Returns
        =======
        :class:`bool`
                True means it worked without any error.
                False means there was an unknown error
        Examples
        --------
        >>> register_font("C:/home/roboto.tff")
        True
        Raises
        ------
        AssertionError
            Font is missing.
        """
        a=Path(font_path)
        assert a.exists(), f"font doesn't exist at {a.absolute()}"
        font_path = str(a.absolute())
        fontAddStatus = AddFontResourceExW(
            <bytes>font_path,
            FR_PRIVATE,
            0
        )
        if fontAddStatus > 0:
            return True
        else:
            return False


    cpdef bint unregister_font(str font_path):
        """This function unregisters(removes) the font file using
        native Windows API. It is mostly optional to call this.
        Mainly used in tests.
        Parameters
        ==========
        font_path : :class:`str`
            Relative or absolute path to font file.
        Returns
        =======
        :class:`bool`
                True means it worked without any error.
                False means there was an unknown error
        Raises
        ------
        AssertionError
            Font is missing.
        """
        a=Path(font_path)
        assert a.exists(), f"font doesn't exist at {a.absolute()}"
        font_path = str(a.absolute())
        return RemoveFontResourceExW(
            <bytes>font_path,
            FR_PRIVATE,
            0
        )


ELIF UNAME_SYSNAME == "Darwin":
    cpdef bint register_font(str font_path):
        """This function registers the font file using ``CoreText`` API so that
        it is available for use by Pango.
        Parameters
        ==========
        font_path : :class:`str`
            Relative or absolute path to font file.
        Returns
        =======
        :class:`bool`
                True means it worked without any error.
                False means there was an unknown error
        Examples
        --------
        >>> register_font("/home/roboto.tff")
        True
        Raises
        ------
        AssertionError
            Font is missing.
        """
        a = Path(font_path)
        assert a.exists(), f"font doesn't exist at {a.absolute()}"
        font_path_bytes_py = str(a.absolute().as_uri()).encode('utf-8')
        cdef unsigned char* font_path_bytes = <bytes>font_path_bytes_py
        b = len(a.absolute().as_uri())
        cdef CFURLRef cf_url = CFURLCreateWithBytes(NULL, font_path_bytes, b, 0x08000100, NULL)
        return CTFontManagerRegisterFontsForURL(
            cf_url,
            kCTFontManagerScopeProcess,
            NULL
        )


    cpdef bint unregister_font(str font_path):
        """This function unregisters(removes) the font file using
        native ``CoreText`` API. It is mostly optional to call this.
        Mainly used in tests.
        Parameters
        ==========
        font_path : :class:`str`
            Relative or absolute path to font file.
        Returns
        =======
        :class:`bool`
                True means it worked without any error.
                False means there was an unknown error
        Raises
        ------
        AssertionError
            Font is missing.
        """
        a = Path(font_path)
        assert a.exists(), f"font doesn't exist at {a.absolute()}"
        font_path_bytes_py = str(a.absolute().as_uri()).encode('utf-8')
        cdef unsigned char* font_path_bytes = <bytes>font_path_bytes_py
        b = len(a.absolute().as_uri())
        cdef CFURLRef cf_url = CFURLCreateWithBytes(NULL, font_path_bytes, b, 0x08000100, NULL)
        return CTFontManagerUnregisterFontsForURL(
            cf_url,
            kCTFontManagerScopeProcess,
            NULL
        )