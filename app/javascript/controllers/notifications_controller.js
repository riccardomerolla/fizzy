import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { pageIsTurboPreview } from "helpers/turbo_helpers"
import { onNextEventLoopTick } from "helpers/timing_helpers"
export default class extends Controller {
  static values = { subscriptionsUrl: String }

  async connect() {
    const state = await this.getCurrentState()
  
    this.updateUI(state)
  }

  async attemptToSubscribe() {
    if (this.#allowed) {
      const registration = await this.#getServiceWorkerRegistration() || await this.#registerServiceWorker()

      switch(Notification.permission) {
        case "denied":  { console.log("Notification.permission: denied"); break }
        case "granted": { this.#subscribe(registration); break }
        case "default": { this.#requestPermissionAndSubscribe(registration) }
      }
    } else {
      console.log("Should display not-allowed notice")
    }
  }

  async isEnabled() {
    if (this.#allowed) {
      const registration = await this.#getServiceWorkerRegistration()
      const existingSubscription = await registration?.pushManager?.getSubscription()

      return Notification.permission == "granted" && registration && existingSubscription
    } else {
      console.log("Not alllowed")
      return false
    }
  }

  get #allowed() {
    return navigator.serviceWorker && window.Notification
  }

  async #getServiceWorkerRegistration() {
    return navigator.serviceWorker.getRegistration("/service-worker.js", { scope: "/" })
  }

  #registerServiceWorker() {
    return navigator.serviceWorker.register("/service-worker.js", { scope: "/" })
  }

  async #subscribe(registration) {
    registration.pushManager
      .subscribe({ userVisibleOnly: true, applicationServerKey: this.#vapidPublicKey })
      .then(subscription => {
        this.#syncPushSubscription(subscription)
      })
  }

  async #syncPushSubscription(subscription) {
    const response = await post(this.subscriptionsUrlValue, { body: this.#extractJsonPayloadAsString(subscription), responseKind: "turbo-stream" })
    if (!response.ok) subscription.unsubscribe()
  }

  async #requestPermissionAndSubscribe(registration) {
    const permission = await Notification.requestPermission()
    if (permission === "granted") this.#subscribe(registration)
  }

  get #vapidPublicKey() {
    const encodedVapidPublicKey = document.querySelector('meta[name="vapid-public-key"]').content
    console.log('Raw VAPID key:', encodedVapidPublicKey)
    console.log('Key length:', encodedVapidPublicKey.length)
    
    const result = this.#urlBase64ToUint8Array(encodedVapidPublicKey)
    console.log('Decoded key length:', result.length)
    console.log('First few bytes:', Array.from(result.slice(0, 10)))
    return result
  }

  #extractJsonPayloadAsString(subscription) {
    const { endpoint, keys: { p256dh, auth } } = subscription.toJSON()
    return JSON.stringify({ push_subscription: { endpoint, p256dh_key: p256dh, auth_key: auth } })
  }

  // VAPID public key comes encoded as base64 but service worker registration needs it as a Uint8Array
  #urlBase64ToUint8Array(base64String) {
    base64String = base64String.trim()
    
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i) & 0xff
    }

    return outputArray
  }

  updateUI(state) {
    console.log(state)
  }

  async getCurrentState() {
    if (!this.#allowed) {
      return { status: 'not-supported' }
    }

    const registration = await this.#getServiceWorkerRegistration()
    const subscription = await registration?.pushManager?.getSubscription()
    
    return {
      permission: Notification.permission,
      hasRegistration: !!registration,
      hasSubscription: !!subscription,
      status: this.#determineStatus(Notification.permission, registration, subscription)
    }
  }

  #determineStatus(permission, registration, subscription) {
    if (permission === "denied") return "permission-denied"
    if (permission === "default") return "permission-not-requested"
    if (permission === "granted") {
      if (!registration) return "service-worker-missing"
      if (!subscription) return "subscription-missing"
      return "enabled"
    }
    return "unknown"
  }
}
