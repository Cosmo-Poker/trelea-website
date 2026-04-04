#!/bin/bash
# Regenerate screenshots/index.html from directory contents
DIR="$(dirname "$0")/screenshots"
INDEX="$DIR/index.html"

# Collect all non-html files
FILES=()
while IFS= read -r f; do
  FILES+=("$(basename "$f")")
done < <(find "$DIR" -maxdepth 1 -type f ! -name 'index.html' ! -name '.*' | sort)

# Build JSON array for the file list
JSON="["
for i in "${!FILES[@]}"; do
  [ $i -gt 0 ] && JSON+=","
  JSON+="\"${FILES[$i]}\""
done
JSON+="]"

cat > "$INDEX" << 'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Screenshots — Trelea, Inc.</title>
  <style>
    body {
      font-family: system-ui, sans-serif;
      background: #0d1117;
      color: #c9d1d9;
      padding: 2rem;
      max-width: 900px;
      margin: 0 auto;
    }
    h1 { color: #e6edf3; font-size: 1.5rem; margin-bottom: 1rem; }
    a { color: #6c8aff; text-decoration: underline; }
    a:hover { color: #8da4ff; }
    .file-list { list-style: none; padding: 0; }
    .file-list li { padding: 8px 0; border-bottom: 1px solid #21262d; }
    img.thumb {
      max-width: 100%;
      border-radius: 8px;
      margin-top: 8px;
      border: 1px solid #30363d;
    }
  </style>
</head>
<body>
  <h1>Screenshots</h1>
  <ul class="file-list" id="files"></ul>
  <script>
    const files =
HEADER

echo "      $JSON;" >> "$INDEX"

cat >> "$INDEX" << 'FOOTER'
    const ul = document.getElementById('files');
    files.forEach(f => {
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = encodeURIComponent(f);
      a.textContent = f;
      li.appendChild(a);
      li.appendChild(document.createElement('br'));
      const img = document.createElement('img');
      img.src = encodeURIComponent(f);
      img.className = 'thumb';
      img.loading = 'lazy';
      li.appendChild(img);
      li.appendChild(document.createElement('br'));
      ul.appendChild(li);
    });
  </script>
</body>
</html>
FOOTER

echo "Generated $INDEX with ${#FILES[@]} files"
