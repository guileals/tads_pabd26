import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "dvdrental.settings")

import django
django.setup()

from backend.models import Actor

print("Total de atores: ", Actor.objects.count())