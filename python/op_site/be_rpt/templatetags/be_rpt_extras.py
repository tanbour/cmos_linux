"""custom template filters"""
from django import template

register = template.Library()

@register.filter(name="s_split")
def s_split(value, arg):
    """custom filter to split string"""
    return value.split(arg)

@register.filter(name="to_int")
def to_int(value):
    """custom filter to convert string to int"""
    return int(value)

@register.filter(name="get_value")
def get_value(value, arg):
    """custom filter to get dict value"""
    return value.get(arg)

@register.filter(name="to_lu")
def to_lu(value):
    """custom filter to replace spaces with underscores"""
    return value.replace(" ", "_").lower()
