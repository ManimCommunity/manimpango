import typing as T
import copy
from ..exceptions import CairoException

cdef class BaseRenderer:
    # This class should contain things
    # should provide API to render to an SVG
    # or get the buffer.
    def __init__(self):
        pass
    cpdef bint render(self):
        pass
    cdef str is_context_fine(self):
        cdef cairo_status_t status
        status = cairo_status(self.context)
        if status == CAIRO_STATUS_NO_MEMORY:
            cairo_destroy(self.context)
            cairo_surface_destroy(self.surface)
            g_object_unref(self.layout)
            raise MemoryError("Cairo isn't finding memory")
        elif status != CAIRO_STATUS_SUCCESS:
            return copy.deepcopy(cairo_status_to_string(status).decode())
        return ""

cdef class SVGRenderer(BaseRenderer):
    def __cinit__(
        self,
        file_name: str,
        width:int,
        height:int,
        move_to: T.Tuple[int,int] = (0,0)
    ):
        cdef cairo_status_t status
        surface = cairo_svg_surface_create(
            file_name.encode("utf-8"),
            width,
            height
        )
        if surface == NULL:
            raise MemoryError("Cairo.SVGSurface can't be created.")
        context = cairo_create(surface)
        status = cairo_status(context)

        if context == NULL or status == CAIRO_STATUS_NO_MEMORY:
            cairo_destroy(context)
            cairo_surface_destroy(surface)
            raise MemoryError("Cairo.Context can't be created.")
        elif status != CAIRO_STATUS_SUCCESS:
            cairo_destroy(context)
            cairo_surface_destroy(surface)
            raise Exception(cairo_status_to_string(status))

        cairo_move_to(context,move_to[0],move_to[1])

        # Create a Pango layout.
        layout = pango_cairo_create_layout(context)
        if layout==NULL:
            cairo_destroy(context)
            cairo_surface_destroy(surface)
            raise MemoryError("Pango.Layout can't be created from Cairo Context.")

        # Now set the created things as attributes.
        self.surface = surface
        self.context = context
        self.layout = layout

    def __init__(self, file_name: str, width:int, height:int, move_to: T.Tuple[int,int] = (0,0)):
        self.file_name = file_name
        self.width = width
        self.height = height

    def __copy__(self):
        raise NotImplementedError

    def __deepcopy__(self):
        raise NotImplementedError

    cpdef bint render(self):
        cdef cairo_t* context
        cdef cairo_surface_t* surface
        cdef PangoLayout* layout
        # check whether cairo is happy till now
        # else error out or it may create SegFaults.
        status = self.is_context_fine()
        if status:
            raise CairoException(status)
        context = self.context
        surface = self.surface
        layout = self.layout
        pango_cairo_show_layout(context, layout)

        # check for status again
        status = self.is_context_fine()
        if status:
            raise CairoException(status)

        # should I clean it up here?
        # In that case calling this function
        # will result in SegFaults.
        # I think calling this function again
        # is waste.
        g_object_unref(self.layout)
        cairo_destroy(self.context)
        cairo_surface_destroy(self.surface)
        return True
    def __dealloc__(self):
        g_object_unref(self.layout)
        cairo_destroy(self.context)
        cairo_surface_destroy(self.surface)
