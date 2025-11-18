abstract class LiveListIntent {}

class LoadLivesIntent extends LiveListIntent {}

class CreateLiveIntent extends LiveListIntent {
  final String title;
  final String description;
  final DateTime scheduledDate;
  final int goalAmountCents;
  CreateLiveIntent(this.title, this.description, this.scheduledDate, this.goalAmountCents);
}

class StartLiveIntent extends LiveListIntent {
  final String liveId;
  StartLiveIntent(this.liveId);
}

class FinishLiveIntent extends LiveListIntent {
  final String liveId;
  FinishLiveIntent(this.liveId);
}

class DeleteLiveIntent extends LiveListIntent {
  final String liveId;
  DeleteLiveIntent(this.liveId);
}