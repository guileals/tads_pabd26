from rest_framework import mixins, viewsets

from . import serializers
from . import models


class ReadOnlyListViewSet(mixins.ListModelMixin, viewsets.GenericViewSet):
    pagination_class = None


class ActorViewSet(ReadOnlyListViewSet):
    queryset = models.Actor.objects.all()
    serializer_class = serializers.ActorSerializer


class AddressViewSet(ReadOnlyListViewSet):
    queryset = models.Address.objects.all()
    serializer_class = serializers.AddressSerializer


class CategoryViewSet(ReadOnlyListViewSet):
    queryset = models.Category.objects.all()
    serializer_class = serializers.CategorySerializer


class CityViewSet(ReadOnlyListViewSet):
    queryset = models.City.objects.all()
    serializer_class = serializers.CitySerializer


class CountryViewSet(ReadOnlyListViewSet):
    queryset = models.Country.objects.all()
    serializer_class = serializers.CountrySerializer


class CustomerViewSet(ReadOnlyListViewSet):
    queryset = models.Customer.objects.all()
    serializer_class = serializers.CustomerSerializer


class CustomerSpendingViewSet(ReadOnlyListViewSet):
    queryset = models.CustomerSpending.objects.all()
    serializer_class = serializers.CustomerSpendingSerializer


class FilmViewSet(ReadOnlyListViewSet):
    queryset = models.Film.objects.all()
    serializer_class = serializers.FilmSerializer


class FilmActorViewSet(ReadOnlyListViewSet):
    queryset = models.FilmActor.objects.all()
    serializer_class = serializers.FilmActorSerializer


class FilmCategoryViewSet(ReadOnlyListViewSet):
    queryset = models.FilmCategory.objects.all()
    serializer_class = serializers.FilmCategorySerializer


class InventoryViewSet(ReadOnlyListViewSet):
    queryset = models.Inventory.objects.all()
    serializer_class = serializers.InventorySerializer


class LanguageViewSet(ReadOnlyListViewSet):
    queryset = models.Language.objects.all()
    serializer_class = serializers.LanguageSerializer


class PaymentViewSet(ReadOnlyListViewSet):
    queryset = models.Payment.objects.all()
    serializer_class = serializers.PaymentSerializer


class RentalViewSet(ReadOnlyListViewSet):
    queryset = models.Rental.objects.all()
    serializer_class = serializers.RentalSerializer


class StaffViewSet(ReadOnlyListViewSet):
    queryset = models.Staff.objects.all()
    serializer_class = serializers.StaffSerializer


class StoreViewSet(ReadOnlyListViewSet):
    queryset = models.Store.objects.all()
    serializer_class = serializers.StoreSerializer
