from rest_framework import serializers
from decimal import Decimal

from .models import (
    Actor,
    Address,
    Category,
    City,
    Country,
    Customer,
    CustomerSpending,
    Film,
    FilmActor,
    FilmCategory,
    Inventory,
    Language,
    Payment,
    Rental,
    Staff,
    Store,
)


class ActorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actor
        fields = "__all__"


class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = "__all__"


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = "__all__"


class CitySerializer(serializers.ModelSerializer):
    class Meta:
        model = City
        fields = "__all__"


class CountrySerializer(serializers.ModelSerializer):
    class Meta:
        model = Country
        fields = "__all__"


class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = "__all__"


class CustomerSpendingSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomerSpending
        fields = "__all__"


class FilmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Film
        fields = "__all__"


class FilmLengthRangeSerializer(serializers.Serializer):
    len_from = serializers.IntegerField(min_value=0)
    len_to = serializers.IntegerField(min_value=0)

    # validate - método que pode ser sobrescrito em um serializer para adicionar validação personalizada
    def validate(self, attrs):
        if attrs["len_from"] > attrs["len_to"]:
            raise serializers.ValidationError(
                {"len_to": "Deve ser maior ou igual que len_from"}
            )
        return attrs


class FilmActorSerializer(serializers.ModelSerializer):
    class Meta:
        model = FilmActor
        fields = "__all__"


class FilmCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = FilmCategory
        fields = "__all__"


class InventorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Inventory
        fields = "__all__"


class LanguageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Language
        fields = "__all__"


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = "__all__"


class RentalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rental
        fields = "__all__"


class RegisterRentalSerializer(serializers.Serializer):
    customer_id = serializers.IntegerField(min_value=1)
    inventory_id = serializers.IntegerField(min_value=1)
    staff_id = serializers.IntegerField(min_value=1)
    amount = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        min_value=Decimal("0.01")
    )


class StaffSerializer(serializers.ModelSerializer):
    class Meta:
        model = Staff
        exclude = ("password", "picture")


class StoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Store
        fields = "__all__"
