import 'package:flutter/material.dart';
import '../services/mahasiswa_services.dart';
import '../models/mahasiswa.dart';

class MahasiswaPage extends StatefulWidget {
  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {

  final MahasiswaService service = MahasiswaService();

  List<Mahasiswa> data = [];

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController jurusanController = TextEditingController();

  int? updateNum;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {

    final result = await service.getAll();

    setState(() {
      data = result;
    });
  }

  void tambahMahasiswa() async {

    final mahasiswa = Mahasiswa(
      nama: namaController.text,
      nim: nimController.text,
      jurusan: jurusanController.text,
    );

    await service.tambah(mahasiswa);

    loadData();

    namaController.clear();
    nimController.clear();
    jurusanController.clear();
  }

  void hapusMahasiswa(int id) async {

    await service.hapus(id);

    loadData();
  }

  void updateMahasiswa() async {

    final mahasiswa = Mahasiswa(
      id: updateNum,
      nama: namaController.text,
      nim: nimController.text,
      jurusan: jurusanController.text,
    );

    await service.update(mahasiswa);

    loadData();

    namaController.clear();
    nimController.clear();
    jurusanController.clear();

    setState(() {
      isUpdate = false;
      updateNum = null;
    });
  }

  void editMode(Mahasiswa mhs) {

    namaController.text = mhs.nama;
    nimController.text = mhs.nim;
    jurusanController.text = mhs.jurusan;

    setState(() {
      isUpdate = true;
      updateNum = mhs.id;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Daftar Mahasiswa")),

      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: "Nama"),
            ),

            TextField(
              controller: nimController,
              decoration: InputDecoration(labelText: "NIM"),
            ),

            TextField(
              controller: jurusanController,
              decoration: InputDecoration(labelText: "Jurusan"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: isUpdate ? updateMahasiswa : tambahMahasiswa,
              child: Text(isUpdate ? "Simpan" : "Tambah"),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {

                  final mhs = data[index];

                  return ListTile(
                    title: Text(mhs.nama),
                    subtitle: Text("${mhs.nim} - ${mhs.jurusan}"),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            editMode(mhs);
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            hapusMahasiswa(mhs.id!);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}