# Script Version 5

set -g clipboard_file /home/i/Clipboard/clipboard.txt
set -g cut_storage /home/i/Clipboard/cut_storage
mkdir -p $cut_storage

function green
    set_color green
    echo $argv
    set_color normal
end

function copyall
    echo -n "" >$clipboard_file
    for f in *
        if test -e "$f"
            echo (realpath "$f") >>$clipboard_file
            green "📋 Copied: $f"
        end
    end
end

function cutall
    echo -n "" >$clipboard_file
    for f in *
        if test -e "$f"
            echo "$cut_storage/$f" >>$clipboard_file
            mv "$f" "$cut_storage/"
            green "✂️ Cut: $f"
        end
    end
end

function copy
    if test (count $argv) -eq 0
        echo "Usage: copy <file1> [file2 ...]"
        return 1
    end
    echo -n "" >$clipboard_file
    for f in $argv
        if test -e "$f"
            echo (realpath "$f") >>$clipboard_file
            green "📋 Copied: $f"
        else
            echo "⚠️ Not found: $f"
        end
    end
end

function cut
    if test (count $argv) -eq 0
        echo "Usage: cut <file1> [file2 ...]"
        return 1
    end
    echo -n "" >$clipboard_file
    for f in $argv
        if test -e "$f"
            echo "$cut_storage/$f" >>$clipboard_file
            mv "$f" "$cut_storage/"
            green "✂️ Cut: $f"
        else
            echo "⚠️ Not found: $f"
        end
    end
end

function pasteall
    if not test -s $clipboard_file
        echo "📎 Clipboard is empty"
        return
    end

    for path in (cat $clipboard_file)
        set name (basename "$path")
        if test -e "$path"
            green "📄 Pasting: $name"
            pv "$path" >"$name"
        else if test -e "$cut_storage/$name"
            green "✂️ Moving: $name"
            mv "$cut_storage/$name" .
        else
            echo "⚠️ Not found: $name"
        end
    end

    echo -n "" >$clipboard_file
    echo "✅ Paste complete"
end

function paste
    if not test -s $clipboard_file
        echo "📎 Clipboard is empty"
        return
    end

    for name in $argv
        set match (grep "/$name\$" $clipboard_file)
        if test -n "$match"
            if test -e "$match"
                green "📄 Pasting: $name"
                pv "$match" >"$name"
            else if test -e "$cut_storage/$name"
                green "✂️ Moving: $name"
                mv "$cut_storage/$name" .
            end
        else
            echo "⚠️ Not in clipboard: $name"
        end
    end
end

function clipboard
    if test (count $argv) -eq 0
        echo "Usage: clipboard [show|clear]"
        return
    end

    switch $argv[1]
        case show
            green "📋 Clipboard contents:"
            cat $clipboard_file
        case clear
            echo -n "" >$clipboard_file
            green "🧹 Clipboard cleared"
        case '*'
            echo "Usage: clipboard [show|clear]"
    end
end
