import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

Widget buildToast(BuildContext context, ToastOverlay overlay) {
  String formattedDate = DateFormat(
    'EEEE, MMMM dd, yyyy \'at\' hh:mm a',
  ).format(DateTime.now());

  return SurfaceCard(
    child: Basic(
      title: const Text("Task Updated"),
      subtitle: Text(formattedDate),
      trailing: PrimaryButton(
        size: ButtonSize.small,
        onPressed: () {
          overlay.close();
        },
        child: const Text('Done'),
      ),
      trailingAlignment: Alignment.center,
    ),
  );
}
