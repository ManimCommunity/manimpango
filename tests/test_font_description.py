# -*- coding: utf-8 -*-
import copy

from manimpango import FontDescription


def test_init():
    FontDescription()


def test_equality():
    first = FontDescription()
    second = FontDescription()
    assert first == second


def test_copy():
    first = FontDescription()
    second = copy.copy(first)
    assert first == second


def test_family_property():
    desc = FontDescription()
    assert desc.family is None
    desc.family = "Roboto"
    assert desc.family == "Roboto"


def test_size_property():
    desc = FontDescription()
    assert desc.size == 0
    desc.size = 20
    assert desc.size == 20
    assert desc.size_is_absolute is False
