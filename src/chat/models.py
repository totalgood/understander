from django.db import models
# from django.contrib.auth.models import User
from django.contrib.auth import get_user_model
User = get_user_model()


class Statement(models.Model):
    text = models.CharField(max_length=250)
    user = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE)
    pub_date = models.DateTimeField('timestamp')
