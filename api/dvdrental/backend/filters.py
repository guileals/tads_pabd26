from django_filters import rest_framework as django_filters
from . import models

class FilmFilter(django_filters.FilterSet):
    title = django_filters.CharFilter(
        field_name="title",
        lookup_expr="icontains",
    )

    rating = django_filters.CharFilter(
        field_name="rating",
        lookup_expr="icontains",
    )

    rental_rate_min = django_filters.NumberFilter(
        field_name="rental_rate",
        lookup_expr="gte",
    )

    rental_rate_max = django_filters.NumberFilter(
        field_name="rental_rate",
        lookup_expr="lte",
    )

    length_min = django_filters.NumberFilter(
        field_name="rental_rate",
        lookup_expr="gte",
    )

    length_max = django_filters.NumberFilter(
        field_name="rental_rate",
        lookup_expr="lte",
    )

    class Meta:
        model = models.Film
        fields = []