namespace :links do
  desc "만료된 링크를 삭제합니다"
  task cleanup_expired: :environment do
    expired_count = Link.where("expires_at < ?", Time.current).count

    if expired_count > 0
      Link.where("expires_at < ?", Time.current).destroy_all
      puts "#{expired_count}개의 만료된 링크가 삭제되었습니다."
    else
      puts "삭제할 만료된 링크가 없습니다."
    end
  end
end
