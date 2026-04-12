namespace :active_storage do
  desc <<~DESC
    Find every Active Storage attachment whose backing file is missing from
    storage and purge it (removes both the blob record and the attachment row).

    Safe to run in any environment. Prints a summary when done.

    Usage:
      rails active_storage:purge_orphans            # dry-run (default)
      rails active_storage:purge_orphans PURGE=true # actually delete
  DESC
  task purge_orphans: :environment do
    dry_run  = ENV["PURGE"] != "true"
    service  = ActiveStorage::Blob.service
    found    = 0
    purged   = 0

    puts dry_run ? "[DRY RUN] Pass PURGE=true to actually delete records." : "[LIVE] Purging orphaned attachments..."
    puts

    ActiveStorage::Attachment.includes(:blob).find_each do |attachment|
      blob = attachment.blob
      next if service.exist?(blob.key)

      found += 1
      owner = "#{attachment.record_type}##{attachment.record_id}"
      puts "  MISSING  #{owner}  →  #{blob.filename} (key: #{blob.key})"

      unless dry_run
        attachment.purge   # removes attachment row + blob row + file (no-op if file already gone)
        purged += 1
      end
    end

    puts
    if found.zero?
      puts "No orphaned attachments found. Storage is clean."
    elsif dry_run
      puts "#{found} orphaned attachment(s) found. Run with PURGE=true to remove them."
    else
      puts "Purged #{purged} / #{found} orphaned attachment(s)."
    end
  end
end
