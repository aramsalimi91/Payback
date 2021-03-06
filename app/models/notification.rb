# == Schema Information
#
# Table name: notifications
#
#  id           :integer          not null, primary key
#  notif_type   :string(255)
#  read         :boolean          default(FALSE)
#  expense_id   :integer
#  user_from_id :integer
#  user_to_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Notification < ActiveRecord::Base

  MARKOFF  = 'mark_off'
  NEW_DEBT = 'new_debt'
  PAYMENT  = 'payment'
  COMM_TYPES = [
    MARKOFF,
    NEW_DEBT,
  ]

  attr_accessible :user_from_id, :user_to_id, :notif_type, :read

  has_and_belongs_to_many :expenses

  belongs_to :user_from, class_name: 'User'
  belongs_to :user_to,   class_name: 'User'

  def unread?
    !read
  end

  def mark_as_read!
    update_attributes! read: true
  end

  def expense_title
    expense.try(:title) || ''
  end

  def deliver_mail
    case notif_type
    when Notification::MARKOFF
      expense = expenses.first
      recipient = expense.creditor
      if recipient.receive_communication?(Notification::MARKOFF)
        NotificationsMailer.delay.mark_off(expense.id)
      end
    end
  end

end
