class StoredValue < ApplicationRecord
  include CSVAttributes
  
  CSV_ATTRIBUTES = %w[ id storable_id storable_type key value group_id ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  belongs_to :storable, :polymorphic => true
  belongs_to :group
  validates :key, :presence => true
  validates :storable, :presence => true
  validate :key_is_allowed_for_storable

  scope :with_key, -> (name) { where(:key => name) }

  def key_is_allowed_for_storable
    if storable && !storable.storable_keys.include?(key.to_s)
      storable_type = if storable.class.reflect_on_all_associations(:belongs_to).map(&:name).include?(:group)
        storable.grouped_name
      else
        storable.class.to_s
      end
      errors[:key] << "must be a storable key valid for #{storable_type}"
    end
  end
end
