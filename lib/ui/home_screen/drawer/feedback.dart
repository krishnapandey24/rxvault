import 'package:flutter/material.dart';
import 'package:rxvault/ui/widgets/drop_down_selector.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:rxvault/utils/user_manager.dart';

import '../../../network/api_service.dart';
import '../../../utils/utils.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  late Size size;
  final TextEditingController _controller = TextEditingController();
  final List<String> types = ["Feedback", "Suggestion", "Complaint"];
  late String selectedType = types[0];
  final api = API();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Utils.getDefaultAppBar("Feedback"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropDownSelector(
                options: types,
                setSelection: (selection) {
                  selectedType = selection;
                },
                label: "Select type",
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                minLines: 10,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your text here...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                ),
                onPressed: _submitFeedback,
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _submitFeedback() async {
    Utils.showLoader(context);
    try {
      String text = _controller.text;
      String? userId = await UserManager.getUserId();
      await api.submitFeedback(text, userId ?? "0", selectedType);
      Utils.toast("$selectedType submitted successfully");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }
}
