# LEGACY (Do Not Edit)

Bu klasör, geçmiş/ham/metinleri saklamak içindir. Amaç:
- Tarihçe kaybolmasın
- Yeni dokümanlar temiz yazılsın
- Eski içerik “referans” olarak dursun

## Kurallar
- Buraya alınan dosyalar *editlemeyiz*. Gerekirse yeni dosyada yeniden yazarız.
- Taşıma: `git mv <eski> docs/PENA/NOTES/LEGACY/<date>/<aynı-ad>.md`
- Secrets yok: şifre/token/key görürsen *hemen sil*, git history’ye girmeden düzelt.

## Akış
1) Eski dokümanı LEGACY’ye taşı
2) `docs/PENA/NOTES/REWRITE-QUEUE.md` içinde kaynağı işaretle
3) Canonical hedef dokümanı yeniden yaz
4) Gerekirse eski dosyaya link ver (ama canonical’i kirletme)
