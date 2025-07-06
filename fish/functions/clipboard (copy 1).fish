# clipboard.fish - Fish shell clipboard system

set -g clipboard_file /home/i/Clipboard/clipboard.txt
set -g cut_storage /home/i/Clipboard/cut_storage
mkdir -p $cut_storage

function lsn --description 'List files with index'
    set i 1
    for f in *
        echo "$i) $f"
        set i (math $i + 1)
    end
end

function parse_indices --argument-names start _to end --description 'Generate file list by index'
    set files (ls -A)
    set result

    for i in (seq $start $end)
        set result $result $files[(math $i)]
    end

    if contains -- without $argv
        set w_index (contains -i -- 'without' $argv)
        set exclude_args $argv[(math $w_index + 1)..-1]
        set to_exclude

        for arg in $exclude_args
            if test $arg = to
                continue
            else if string match -rq '^\d+$' -- $arg
                set to_exclude $to_exclude $arg
            end
        end

        for ex in $to_exclude
            set item $files[(math $ex)]
            set result (string match -v "$item" $result)
        end
    end

    echo $result
end

function copy --description 'Copy files by name or index'
    echo -n "" >$clipboard_file

    if test (count $argv) -eq 1 -a "$argv[1]" = all
        for f in *
            echo (realpath $f) >>$clipboard_file
            echo "📋 Copied: $f"
        end
        return
    end

    if contains to $argv
        set selected (parse_indices $argv)
        for f in $selected
            echo (realpath $f) >>$clipboard_file
            echo "📋 Copied: $f"
        end
    else
        for f in $argv
            if test -e $f
                echo (realpath $f) >>$clipboard_file
                echo "📋 Copied: $f"
            else
                echo "⚠️ Not found: $f"
            end
        end
    end
end

function cut --description 'Cut files by name or index'
    echo -n "" >$clipboard_file
    mkdir -p $cut_storage

    if test (count $argv) -eq 1 -a "$argv[1]" = all
        for f in *
            echo "$cut_storage/$f" >>$clipboard_file
            mv $f $cut_storage/
            echo "✂️ Cut: $f"
        end
        return
    end

    if contains to $argv
        set selected (parse_indices $argv)
        for f in $selected
            echo "$cut_storage/$f" >>$clipboard_file
            mv $f $cut_storage/
            echo "✂️ Cut: $f"
        end
    else
        for f in $argv
            if test -e $f
                echo "$cut_storage/$f" >>$clipboard_file
                mv $f $cut_storage/
                echo "✂️ Cut: $f"
            else
                echo "⚠️ Not found: $f"
            end
        end
    end
end

function pasteall --description 'Paste all items from clipboard'
    if not test -s $clipboard_file
        echo "📎 Clipboard is empty"
        return
    end

    for line in (cat $clipboard_file)
        set name (basename $line)
        if test -e $line
            echo "📄 Pasting: $name"
            pv $line >$name
        else if test -e "$cut_storage/$name"
            echo "✂️ Moving: $name"
            mv "$cut_storage/$name" .
        else
            echo "⚠️ Not found: $name"
        end
    end
    echo -n "" >$clipboard_file
    echo "✅ Paste complete"
end

function paste --description 'Paste specific items from clipboard'
    if not test -s $clipboard_file
        echo "📎 Clipboard is empty"
        return
    end

    for name in $argv
        set match (grep "/$name\$" $clipboard_file)
        if test -n "$match"
            if test -e "$match"
                echo "📄 Pasting: $name"
                pv "$match" >"$name"
            else if test -e "$cut_storage/$name"
                echo "✂️ Moving: $name"
                mv "$cut_storage/$name" .
            end
        else
            echo "⚠️ $name not in clipboard"
        end
    end
end

function copyall --description 'Copy all files and folders'
    copy all
end

function cutall --description 'Cut all files and folders'
    cut all
end
