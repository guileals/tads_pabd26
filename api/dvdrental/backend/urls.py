from rest_framework.routers import DefaultRouter

from . import views

from django.urls import path

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

router = DefaultRouter()
router.register('actors', views.ActorViewSet, basename='actor')
router.register('addresses', views.AddressViewSet, basename='address')
router.register('categories', views.CategoryViewSet, basename='category')
router.register('cities', views.CityViewSet, basename='city')
router.register('countries', views.CountryViewSet, basename='country')
router.register('customers', views.CustomerViewSet, basename='customer')
router.register(
    'customer-spending',
    views.CustomerSpendingViewSet,
    basename='customer-spending',
)
router.register('films', views.FilmViewSet, basename='film')
router.register('film-actors', views.FilmActorViewSet, basename='film-actor')
router.register(
    'film-categories',
    views.FilmCategoryViewSet,
    basename='film-category',
)
router.register('inventory', views.InventoryViewSet, basename='inventory')
router.register('languages', views.LanguageViewSet, basename='language')
router.register('payments', views.PaymentViewSet, basename='payment')
router.register('rentals', views.RentalViewSet, basename='rental')
router.register('staff', views.StaffViewSet, basename='staff')
router.register('stores', views.StoreViewSet, basename='store')

urlpatterns = [
    path(
        "auth/token/",
        TokenObtainPairView.as_view(),
        name="token_obtain_pair",
    ),
    path(
        "auth/token/refresh/",
        TokenRefreshView.as_view(),
        name="token_refresh",
    ),
    path(
        "auth/token/verify/",
        TokenVerifyView.as_view(),
        name="token_verify",
    ),
    path(
        "auth/me/",
        views.UserProfileView.as_view(),
        name="user_profile",
    ),
] + router.urls

