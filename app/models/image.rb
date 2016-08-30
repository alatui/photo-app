class Image < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader
  validate :picture_size
  validate :name_cannot_be_test

  private

    def picture_size
      if picture.size > 3.megabytes
        errors.add(:picture, 'should be less than 3MB')
      end
    end

  def name_cannot_be_test
    if name == 'test'
      errors.add(:name, 'should not be test');
    end
  end

end
