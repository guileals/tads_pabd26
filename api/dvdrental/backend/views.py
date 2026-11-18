from .filters import FilmFilter
from rest_framework import mixins, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from . import serializers
from . import models
from . import services

from rest_framework.generics import RetrieveAPIView
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from drf_spectacular.utils import (
    OpenApiResponse,
    extend_schema,
)

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters


class UserProfileView(RetrieveAPIView):
    serializer_class = serializers.UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class ReadOnlyListViewSet(
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    pagination_class = None
    permission_classes = [IsAuthenticated]


class ActorViewSet(ReadOnlyListViewSet):
    permission_classes = [AllowAny]
    queryset = models.Actor.objects.all()
    serializer_class = serializers.ActorSerializer

    filter_backends = [
        filters.SearchFilter,
        filters.OrderingFilter,
    ]

    search_fields = [
        "first_name",
        "last_name",
        # "^first_name" # first_name começando com o termo,
        # "=first_name" # first_name igual ao termo, ignorando maiúsculas
    ]

    ordering_fields = [
        "actor_id",
        "first_name",
        "last_name",
    ]

    ordering = ["first_name", "last_name", "actor_id"]


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

    filter_backends = [
        filters.SearchFilter,
        filters.OrderingFilter,
        DjangoFilterBackend
    ]

    filterset_fields = [
        "store_id",
        "activebool"
    ]

    search_fields = [
        "first_name",
        "last_name",
        "email",
    ]

    ordering_fields = [
        "customer_id",
        "first_name",
        "last_name",
        "create_date",
    ]

    ordering = ["customer_id"]

    # detail=True - ação é aplicada a um único objeto
    # rota criada - /api/customers/{pk}/total-spent
    @action(detail=True, methods=["get"], url_path="total-spent")
    def total_spent(self, request, pk=None):
        customer = self.get_object()
        total_spent = services.customer_total_spent(customer.customer_id)
        return Response(
            {"customer_id": customer.customer_id, "total_spent": total_spent}
        )


class CustomerSpendingViewSet(ReadOnlyListViewSet):
    queryset = models.CustomerSpending.objects.all()
    serializer_class = serializers.CustomerSpendingSerializer


class FilmViewSet(ReadOnlyListViewSet):
    permission_classes = [AllowAny]
    queryset = models.Film.objects.all()
    serializer_class = serializers.FilmSerializer

    filter_backends = [
        filters.SearchFilter,
        filters.OrderingFilter,
        DjangoFilterBackend
    ]

    filterset_class = FilmFilter

    search_fields = [
        "title",
        "description",
    ]

    ordering_fields = [
        "film_id",
        "title",
        "rental_rate"
        "length",
        "release_year",
    ]

    ordering = ["title", "film_id"]

    def _validated_length_range(self, request):
        # request.query_params contém os parâmetros enviados na URL
        query_serializer = serializers.FilmLengthRangeSerializer(
            data=request.query_params
        )
        query_serializer.is_valid(raise_exception=True)
        return query_serializer.validated_data

    # api/films/by-length/?len_from=90&len_to=120
    @action(detail=False, methods=["get"], url_path="by-length")
    def by_length(self, request):
        length_range = self._validated_length_range(request)
        films = services.films_by_length(
            length_range["len_from"], length_range["len_to"]
        )
        return Response(films)


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

    def get_permissions(self):
        if self.action == "register":
            return [IsAdminUser()]

        return [IsAuthenticated()]

    @extend_schema(
        request=serializers.RegisterRentalSerializer,
        responses={
            201: OpenApiResponse(
                description=("Aluguel e pagamento registrados."),
            ),
        },
    )
    @action(detail=False, methods=["post"], url_path="register")
    def register(self, request):
        input_serializer = serializers.RegisterRentalSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)

        services.register_rental_with_payment(**input_serializer.validated_data)

        return Response(
            {"detail": "Aluguel registrado!"},
            status=201,
        )


class StaffViewSet(ReadOnlyListViewSet):
    queryset = models.Staff.objects.all()
    serializer_class = serializers.StaffSerializer


class StoreViewSet(ReadOnlyListViewSet):
    queryset = models.Store.objects.all()
    serializer_class = serializers.StoreSerializer
