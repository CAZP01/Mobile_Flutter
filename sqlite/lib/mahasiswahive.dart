import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mahasiswa.dart';
import '../models/prodi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(MahasiswaAdapter());
  Hive.registerAdapter(ProdiAdapter());

  await Hive.openBox<Mahasiswa>('mahasiswaBox');
  await Hive.openBox<Prodi>('prodiBox');

  var prodiBox = Hive.box<Prodi>('prodiBox');

  if (prodiBox.isEmpty) {
    prodiBox.addAll([
      Prodi(namaProdi: "Informatika"),
      Prodi(namaProdi: "Biologi"),
      Prodi(namaProdi: "Fisika"),
    ]);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MahasiswaPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MahasiswaPage extends StatefulWidget {
  @override
  _MahasiswaPageState createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final Box<Mahasiswa> box = Hive.box<Mahasiswa>('mahasiswaBox');
  final Box<Prodi> prodiBox = Hive.box<Prodi>('prodiBox');

  final namaController = TextEditingController();
  final nimController = TextEditingController();

  int? editIndex;
  int? selectedProdiId;

  void saveData() {
    final mahasiswa = Mahasiswa(
      nama: namaController.text,
      nim: nimController.text,
      prodiId: selectedProdiId!,
    );

    if (editIndex == null) {
      box.add(mahasiswa);
    } else {
      box.putAt(editIndex!, mahasiswa);
      editIndex = null;
    }

    clearForm();
  }

  void editData(int index) {
    final data = box.getAt(index)!;
    final prodi = prodiBox.getAt(data.prodiId);

    namaController.text = data.nama;
    nimController.text = data.nim;
    selectedProdiId = data.prodiId;

    setState(() {
      editIndex = index;
    });
  }

  void deleteData(int index) {
    box.deleteAt(index);
  }

  void clearForm() {
    namaController.clear();
    nimController.clear();
    selectedProdiId = null;

    setState(() {
      editIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD Mahasiswa - Hive")),
      body: Padding(
        padding: EdgeInsets.all(12),
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

            SizedBox(height: 10),

            DropdownButtonFormField<int>(
              value: selectedProdiId,
              hint: Text("Pilih Prodi"),
              items: List.generate(prodiBox.length, (index) {
                final prodi = prodiBox.getAt(index);
                return DropdownMenuItem(
                  value: index,
                  child: Text(prodi!.namaProdi),
                );
              }),
              onChanged: (value) {
                setState(() {
                  selectedProdiId = value;
                });
              },
            ),

            SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: saveData,
                  child: Text(editIndex == null ? "Simpan" : "Update"),
                ),
                SizedBox(width: 10),
                if (editIndex != null)
                  ElevatedButton(
                    onPressed: clearForm,
                    child: Text("Batal"),
                  ),
              ],
            ),

            SizedBox(height: 20),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Mahasiswa> box, _) {
                  if (box.isEmpty) {
                    return Center(child: Text("Belum ada data"));
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final data = box.getAt(index)!;
                      final prodi = prodiBox.getAt(data.prodiId);

                      return Card(
                        child: ListTile(
                          title: Text(data.nama),
                          subtitle: Text(
                            "NIM: ${data.nim} | ${prodi?.namaProdi ?? '-'}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => editData(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteData(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}