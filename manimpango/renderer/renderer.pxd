from cairo cimport *
from glib cimport *
from pango cimport *

cdef class BaseRenderer:
    cdef PangoLayout* layout
    cdef cairo_surface_t* surface
    cdef cairo_t* context
    cpdef bint render(self)
    cdef str is_context_fine(self)

cdef class SVGRenderer(BaseRenderer):
    cdef str file_name
    cdef float width
    cdef float height
