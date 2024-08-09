enum Permission{
  addPatient("Add Patient"),
  updatePatient("Update Patient"),
  addAppointment("Add Visit"),
  addPatientService("Add Amount"),
  updatePatientService("Update Amount"),
  deletePatient("Delete Patient"),
  addImage("Add Image");

  final String text;

  const Permission(this.text);
}


